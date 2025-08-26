#!/usr/bin/env python3
"""
Modular Dashboard Generator
Creates dynamic Grafana dashboards from modular components
"""
import json
import yaml
from pathlib import Path
from typing import Dict, List, Any, Optional, Union
from datetime import datetime
from dataclasses import dataclass, asdict
from config_manager import get_config_manager

@dataclass
class GridPosition:
    """Dashboard panel grid position"""
    h: int  # height
    w: int  # width
    x: int  # x position
    y: int  # y position

@dataclass
class PanelThresholds:
    """Panel threshold configuration"""
    mode: str = "absolute"
    steps: List[Dict[str, Any]] = None
    
    def __post_init__(self):
        if self.steps is None:
            self.steps = [
                {"color": "green", "value": None},
                {"color": "red", "value": 80}
            ]

@dataclass
class PanelTarget:
    """Prometheus query target for panel"""
    expr: str
    legend_format: str = ""
    ref_id: str = "A"
    instant: bool = False

class DashboardComponent:
    """Base class for dashboard components"""
    
    def __init__(self, component_id: str, title: str):
        self.component_id = component_id
        self.title = title
        self.dependencies = []
    
    def generate_panel(self, grid_pos: GridPosition, **kwargs) -> Dict[str, Any]:
        """Generate the panel configuration"""
        raise NotImplementedError("Subclasses must implement generate_panel")
    
    def get_dependencies(self) -> List[str]:
        """Get component dependencies"""
        return self.dependencies

class StatPanel(DashboardComponent):
    """Stat panel component"""
    
    def __init__(self, component_id: str, title: str, targets: List[PanelTarget], 
                 unit: str = "short", decimals: int = 0):
        super().__init__(component_id, title)
        self.targets = targets
        self.unit = unit
        self.decimals = decimals
    
    def generate_panel(self, grid_pos: GridPosition, **kwargs) -> Dict[str, Any]:
        return {
            "datasource": {"type": "prometheus", "uid": "PBFA97CFB590B2093"},
            "fieldConfig": {
                "defaults": {
                    "color": {"mode": "thresholds"},
                    "decimals": self.decimals,
                    "mappings": [],
                    "thresholds": asdict(PanelThresholds()),
                    "unit": self.unit
                }
            },
            "gridPos": asdict(grid_pos),
            "id": hash(self.component_id) % 10000,
            "options": {
                "colorMode": "background",
                "graphMode": "area",
                "justifyMode": "center",
                "orientation": "auto",
                "reduceOptions": {"calcs": ["lastNotNull"]},
                "textMode": "value_and_name"
            },
            "targets": [asdict(target) for target in self.targets],
            "title": self.title,
            "type": "stat"
        }

class TimeSeriesPanel(DashboardComponent):
    """Time series panel component"""
    
    def __init__(self, component_id: str, title: str, targets: List[PanelTarget],
                 unit: str = "short", y_min: Optional[float] = None, y_max: Optional[float] = None):
        super().__init__(component_id, title)
        self.targets = targets
        self.unit = unit
        self.y_min = y_min
        self.y_max = y_max
    
    def generate_panel(self, grid_pos: GridPosition, **kwargs) -> Dict[str, Any]:
        field_config = {
            "defaults": {
                "color": {"mode": "palette-classic"},
                "custom": {
                    "drawStyle": "line",
                    "lineInterpolation": "smooth",
                    "lineWidth": 2,
                    "fillOpacity": 10,
                    "pointSize": 5
                },
                "unit": self.unit
            }
        }
        
        if self.y_min is not None:
            field_config["defaults"]["min"] = self.y_min
        if self.y_max is not None:
            field_config["defaults"]["max"] = self.y_max
        
        return {
            "datasource": {"type": "prometheus", "uid": "PBFA97CFB590B2093"},
            "fieldConfig": field_config,
            "gridPos": asdict(grid_pos),
            "id": hash(self.component_id) % 10000,
            "options": {
                "legend": {
                    "calcs": ["mean", "lastNotNull", "max"],
                    "displayMode": "list",
                    "placement": "bottom",
                    "showLegend": True
                },
                "tooltip": {"mode": "multi", "sort": "desc"}
            },
            "targets": [asdict(target) for target in self.targets],
            "title": self.title,
            "type": "timeseries"
        }

class GaugePanel(DashboardComponent):
    """Gauge panel component"""
    
    def __init__(self, component_id: str, title: str, targets: List[PanelTarget],
                 unit: str = "percent", min_val: float = 0, max_val: float = 100):
        super().__init__(component_id, title)
        self.targets = targets
        self.unit = unit
        self.min_val = min_val
        self.max_val = max_val
    
    def generate_panel(self, grid_pos: GridPosition, **kwargs) -> Dict[str, Any]:
        return {
            "datasource": {"type": "prometheus", "uid": "PBFA97CFB590B2093"},
            "fieldConfig": {
                "defaults": {
                    "color": {"mode": "thresholds"},
                    "mappings": [],
                    "max": self.max_val,
                    "min": self.min_val,
                    "thresholds": {
                        "mode": "absolute",
                        "steps": [
                            {"color": "green", "value": None},
                            {"color": "yellow", "value": 60},
                            {"color": "red", "value": 80}
                        ]
                    },
                    "unit": self.unit
                }
            },
            "gridPos": asdict(grid_pos),
            "id": hash(self.component_id) % 10000,
            "options": {
                "orientation": "auto",
                "reduceOptions": {"calcs": ["lastNotNull"]},
                "showThresholdLabels": True,
                "showThresholdMarkers": True
            },
            "targets": [asdict(target) for target in self.targets],
            "title": self.title,
            "type": "gauge"
        }

class DashboardLayout:
    """Manages dashboard panel layout"""
    
    def __init__(self, columns: int = 24):
        self.columns = columns
        self.current_y = 0
        self.current_x = 0
        self.row_height = 0
    
    def next_position(self, width: int, height: int) -> GridPosition:
        """Calculate next panel position"""
        if self.current_x + width > self.columns:
            # Move to next row
            self.current_y += self.row_height
            self.current_x = 0
            self.row_height = height
        else:
            self.row_height = max(self.row_height, height)
        
        pos = GridPosition(height, width, self.current_x, self.current_y)
        self.current_x += width
        
        return pos
    
    def add_row_break(self):
        """Force a new row"""
        if self.current_x > 0:
            self.current_y += self.row_height
            self.current_x = 0
            self.row_height = 0

class ComponentLibrary:
    """Library of reusable dashboard components"""
    
    def __init__(self):
        self.components = {}
        self.templates = {}
        self._register_builtin_components()
    
    def _register_builtin_components(self):
        """Register built-in components"""
        
        # Executive Overview Components
        self.register_component("system_health_slo", self._create_system_health_slo)
        self.register_component("build_success_rate", self._create_build_success_rate)
        self.register_component("build_duration_p95", self._create_build_duration_p95)
        self.register_component("error_rate", self._create_error_rate)
        
        # Infrastructure Components
        self.register_component("cpu_memory_usage", self._create_cpu_memory_usage)
        self.register_component("disk_usage", self._create_disk_usage)
        self.register_component("system_load", self._create_system_load)
        self.register_component("network_throughput", self._create_network_throughput)
        self.register_component("resource_optimization", self._create_resource_optimization)
        
        # Build & CI/CD Components
        self.register_component("build_timeline", self._create_build_timeline)
        self.register_component("build_duration_heatmap", self._create_build_duration_heatmap)
        self.register_component("pipeline_efficiency", self._create_pipeline_efficiency)
        self.register_component("test_coverage_trends", self._create_test_coverage_trends)
        self.register_component("deployment_success", self._create_deployment_success)
        
        # Application Performance Components
        self.register_component("response_time_distribution", self._create_response_time_distribution)
        self.register_component("cache_hit_ratio", self._create_cache_hit_ratio)
        self.register_component("database_performance", self._create_database_performance)
        self.register_component("api_health", self._create_api_health)
        
        # AI-Powered Analytics Components
        self.register_component("predictive_alerts", self._create_predictive_alerts)
        self.register_component("anomaly_detection", self._create_anomaly_detection)
        self.register_component("capacity_forecasting", self._create_capacity_forecasting)
        self.register_component("failure_prediction", self._create_failure_prediction)
        self.register_component("optimization_suggestions", self._create_optimization_suggestions)
        self.register_component("ai_prediction_accuracy", self._create_ai_prediction_accuracy)
        
        # Security & Compliance Components
        self.register_component("security_score", self._create_security_score)
        self.register_component("security_events", self._create_security_events)
        self.register_component("vulnerability_scan", self._create_vulnerability_scan)
        self.register_component("compliance_status", self._create_compliance_status)
        self.register_component("threat_detection", self._create_threat_detection)
        self.register_component("access_audit", self._create_access_audit)
        
        # Developer Experience Components
        self.register_component("deployment_frequency", self._create_deployment_frequency)
        self.register_component("lead_time", self._create_lead_time)
        self.register_component("change_failure_rate", self._create_change_failure_rate)
        self.register_component("developer_velocity", self._create_developer_velocity)
        self.register_component("code_quality_trends", self._create_code_quality_trends)
        self.register_component("developer_satisfaction", self._create_developer_satisfaction)
        
        # Cost Optimization Components
        self.register_component("cost_efficiency", self._create_cost_efficiency)
        self.register_component("cost_breakdown", self._create_cost_breakdown)
        self.register_component("resource_utilization", self._create_resource_utilization)
        self.register_component("cost_trends", self._create_cost_trends)
        self.register_component("savings_opportunities", self._create_savings_opportunities)
        self.register_component("budget_alerts", self._create_budget_alerts)
        
        # Collaboration & ChatOps Components
        self.register_component("incident_response_time", self._create_incident_response_time)
        self.register_component("team_communication", self._create_team_communication)
        self.register_component("knowledge_sharing", self._create_knowledge_sharing)
        self.register_component("on_call_metrics", self._create_on_call_metrics)
        self.register_component("collaboration_health", self._create_collaboration_health)
    
    def register_component(self, name: str, factory_func):
        """Register a component factory function"""
        self.components[name] = factory_func
    
    def create_component(self, name: str, **kwargs) -> DashboardComponent:
        """Create a component instance"""
        if name not in self.components:
            raise ValueError(f"Unknown component: {name}")
        
        return self.components[name](**kwargs)
    
    def _create_system_health_slo(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="100 - (100 * nestory:http_error_rate)",
            legend_format="System Health SLO"
        )]
        return StatPanel("system_health_slo", "System Health (SLO)", targets, unit="percent")
    
    def _create_build_success_rate(self, **kwargs) -> GaugePanel:
        targets = [PanelTarget(
            expr="100 * nestory:build_success_rate",
            legend_format="Build Success Rate"
        )]
        return GaugePanel("build_success_rate", "Build Success Rate", targets)
    
    def _create_build_duration_p95(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:build_duration_p95",
            legend_format="p95 Build Duration"
        )]
        return StatPanel("build_duration_p95", "Build Duration p95", targets, unit="s")
    
    def _create_error_rate(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="sum(rate(nestory_error_total[5m]))",
            legend_format="Error Rate"
        )]
        return StatPanel("error_rate", "Error Rate", targets, unit="ops")
    
    def _create_cpu_memory_usage(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:cpu_usage_percent",
                legend_format="CPU Usage %"
            ),
            PanelTarget(
                expr="nestory:memory_usage_percent",
                legend_format="Memory Usage %",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("cpu_memory_usage", "CPU & Memory Usage", targets, unit="percent", y_min=0, y_max=100)
    
    def _create_disk_usage(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:disk_usage_percent",
            legend_format="Disk Usage"
        )]
        return StatPanel("disk_usage", "Disk Usage", targets, unit="percent")
    
    # AI-Powered Analytics Components
    def _create_predictive_alerts(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:ai_predicted_issues",
                legend_format="Predicted Issues"
            ),
            PanelTarget(
                expr="nestory:ai_confidence_score",
                legend_format="Confidence Score",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("predictive_alerts", "AI Predictive Alerts", targets, unit="short")
    
    def _create_anomaly_detection(self, **kwargs) -> TimeSeriesPanel:
        targets = [PanelTarget(
            expr="nestory:anomaly_score",
            legend_format="Anomaly Score"
        )]
        return TimeSeriesPanel("anomaly_detection", "Anomaly Detection", targets, unit="short")
    
    def _create_capacity_forecasting(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:predicted_capacity_usage",
                legend_format="Predicted Usage"
            ),
            PanelTarget(
                expr="nestory:current_capacity_usage",
                legend_format="Current Usage",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("capacity_forecasting", "Capacity Forecasting", targets, unit="percent")
    
    def _create_failure_prediction(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:failure_probability",
            legend_format="Failure Risk"
        )]
        return StatPanel("failure_prediction", "Failure Prediction", targets, unit="percent")
    
    def _create_optimization_suggestions(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:optimization_count",
            legend_format="Suggestions Available"
        )]
        return StatPanel("optimization_suggestions", "Optimization Suggestions", targets, unit="short")
    
    # Security & Compliance Components
    def _create_security_score(self, **kwargs) -> GaugePanel:
        targets = [PanelTarget(
            expr="nestory:security_score",
            legend_format="Security Score"
        )]
        return GaugePanel("security_score", "Security Score", targets, min_val=0, max_val=100)
    
    def _create_security_events(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="sum(rate(nestory_security_events_total[5m]))",
                legend_format="Security Events"
            )
        ]
        return TimeSeriesPanel("security_events", "Security Events", targets, unit="ops")
    
    def _create_vulnerability_scan(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:vulnerabilities_high",
            legend_format="High Vulnerabilities"
        )]
        return StatPanel("vulnerability_scan", "Critical Vulnerabilities", targets, unit="short")
    
    def _create_compliance_status(self, **kwargs) -> GaugePanel:
        targets = [PanelTarget(
            expr="nestory:compliance_score",
            legend_format="Compliance %"
        )]
        return GaugePanel("compliance_status", "Compliance Status", targets, min_val=0, max_val=100)
    
    def _create_threat_detection(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:active_threats",
            legend_format="Active Threats"
        )]
        return StatPanel("threat_detection", "Active Threats", targets, unit="short")
    
    def _create_access_audit(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="sum(rate(nestory_access_attempts_total[5m]))",
                legend_format="Access Attempts"
            )
        ]
        return TimeSeriesPanel("access_audit", "Access Audit Trail", targets, unit="ops")
    
    # Developer Experience Components
    def _create_deployment_frequency(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:deployments_per_day",
            legend_format="Deployments/Day"
        )]
        return StatPanel("deployment_frequency", "Deployment Frequency", targets, unit="short")
    
    def _create_lead_time(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:lead_time_hours",
            legend_format="Lead Time"
        )]
        return StatPanel("lead_time", "Lead Time for Changes", targets, unit="h")
    
    def _create_change_failure_rate(self, **kwargs) -> GaugePanel:
        targets = [PanelTarget(
            expr="100 * nestory:change_failure_rate",
            legend_format="Change Failure Rate"
        )]
        return GaugePanel("change_failure_rate", "Change Failure Rate", targets, min_val=0, max_val=30)
    
    def _create_developer_velocity(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:commits_per_day",
                legend_format="Commits/Day"
            ),
            PanelTarget(
                expr="nestory:features_delivered",
                legend_format="Features Delivered",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("developer_velocity", "Developer Velocity", targets, unit="short")
    
    def _create_code_quality_trends(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:code_coverage_percent",
                legend_format="Test Coverage %"
            ),
            PanelTarget(
                expr="nestory:code_quality_score",
                legend_format="Quality Score",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("code_quality_trends", "Code Quality Trends", targets, unit="percent")
    
    def _create_developer_satisfaction(self, **kwargs) -> GaugePanel:
        targets = [PanelTarget(
            expr="nestory:developer_satisfaction_score",
            legend_format="Developer Satisfaction"
        )]
        return GaugePanel("developer_satisfaction", "Developer Satisfaction", targets, min_val=0, max_val=10)
    
    # Cost Optimization Components
    def _create_cost_efficiency(self, **kwargs) -> GaugePanel:
        targets = [PanelTarget(
            expr="nestory:cost_efficiency_score",
            legend_format="Cost Efficiency"
        )]
        return GaugePanel("cost_efficiency", "Cost Efficiency", targets, min_val=0, max_val=100)
    
    def _create_cost_breakdown(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:compute_cost_usd",
                legend_format="Compute"
            ),
            PanelTarget(
                expr="nestory:storage_cost_usd",
                legend_format="Storage",
                ref_id="B"
            ),
            PanelTarget(
                expr="nestory:network_cost_usd",
                legend_format="Network",
                ref_id="C"
            )
        ]
        return TimeSeriesPanel("cost_breakdown", "Cost Breakdown", targets, unit="currencyUSD")
    
    def _create_resource_utilization(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:resource_utilization_cpu",
                legend_format="CPU Utilization"
            ),
            PanelTarget(
                expr="nestory:resource_utilization_memory",
                legend_format="Memory Utilization",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("resource_utilization", "Resource Utilization", targets, unit="percent")
    
    def _create_cost_trends(self, **kwargs) -> TimeSeriesPanel:
        targets = [PanelTarget(
            expr="nestory:monthly_cost_usd",
            legend_format="Monthly Cost"
        )]
        return TimeSeriesPanel("cost_trends", "Cost Trends", targets, unit="currencyUSD")
    
    def _create_savings_opportunities(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:potential_savings_usd",
            legend_format="Potential Savings"
        )]
        return StatPanel("savings_opportunities", "Savings Opportunities", targets, unit="currencyUSD")
    
    def _create_budget_alerts(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:budget_usage_percent",
            legend_format="Budget Usage"
        )]
        return StatPanel("budget_alerts", "Budget Usage", targets, unit="percent")
    
    # Enhanced Infrastructure Components
    def _create_network_throughput(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="rate(nestory_network_bytes_sent[5m])",
                legend_format="Bytes Sent"
            ),
            PanelTarget(
                expr="rate(nestory_network_bytes_received[5m])",
                legend_format="Bytes Received",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("network_throughput", "Network Throughput", targets, unit="binBps")
    
    def _create_resource_optimization(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:resource_optimization_score",
            legend_format="Optimization Score"
        )]
        return StatPanel("resource_optimization", "Resource Optimization", targets, unit="percent")
    
    # AI Prediction Accuracy
    def _create_ai_prediction_accuracy(self, **kwargs) -> GaugePanel:
        targets = [PanelTarget(
            expr="nestory:ai_prediction_accuracy",
            legend_format="AI Accuracy"
        )]
        return GaugePanel("ai_prediction_accuracy", "AI Prediction Accuracy", targets, min_val=0, max_val=100)
    
    # Enhanced Application Performance
    def _create_database_performance(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:db_query_duration_p95",
                legend_format="Query Duration p95"
            ),
            PanelTarget(
                expr="nestory:db_connections_active",
                legend_format="Active Connections",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("database_performance", "Database Performance", targets, unit="ms")
    
    def _create_api_health(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="100 - (100 * nestory:api_error_rate)",
            legend_format="API Health"
        )]
        return StatPanel("api_health", "API Health Score", targets, unit="percent")
    
    # Enhanced CI/CD Components  
    def _create_pipeline_efficiency(self, **kwargs) -> GaugePanel:
        targets = [PanelTarget(
            expr="nestory:pipeline_efficiency_score",
            legend_format="Pipeline Efficiency"
        )]
        return GaugePanel("pipeline_efficiency", "Pipeline Efficiency", targets, min_val=0, max_val=100)
    
    def _create_test_coverage_trends(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:test_coverage_percent",
                legend_format="Test Coverage"
            ),
            PanelTarget(
                expr="nestory:test_execution_time",
                legend_format="Test Duration",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("test_coverage_trends", "Test Coverage & Duration", targets, unit="percent")
    
    def _create_deployment_success(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="100 * nestory:deployment_success_rate",
            legend_format="Deployment Success"
        )]
        return StatPanel("deployment_success", "Deployment Success Rate", targets, unit="percent")
    
    # Collaboration & ChatOps Components
    def _create_incident_response_time(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:incident_response_time_minutes",
            legend_format="Response Time"
        )]
        return StatPanel("incident_response_time", "Incident Response Time", targets, unit="m")
    
    def _create_team_communication(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:chat_messages_per_hour",
                legend_format="Messages/Hour"
            ),
            PanelTarget(
                expr="nestory:active_team_members",
                legend_format="Active Members",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("team_communication", "Team Communication", targets, unit="short")
    
    def _create_knowledge_sharing(self, **kwargs) -> StatPanel:
        targets = [PanelTarget(
            expr="nestory:knowledge_articles_created",
            legend_format="Articles Created"
        )]
        return StatPanel("knowledge_sharing", "Knowledge Sharing", targets, unit="short")
    
    def _create_on_call_metrics(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="nestory:on_call_alerts",
                legend_format="On-call Alerts"
            ),
            PanelTarget(
                expr="nestory:escalations",
                legend_format="Escalations",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("on_call_metrics", "On-call Metrics", targets, unit="short")
    
    def _create_collaboration_health(self, **kwargs) -> GaugePanel:
        targets = [PanelTarget(
            expr="nestory:collaboration_health_score",
            legend_format="Collaboration Health"
        )]
        return GaugePanel("collaboration_health", "Collaboration Health", targets, min_val=0, max_val=100)
    
    def _create_system_load(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="node_load5",
                legend_format="Load Average (5min)"
            ),
            PanelTarget(
                expr="100 * (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes)",
                legend_format="Free Memory %",
                ref_id="B"
            )
        ]
        return TimeSeriesPanel("system_load", "System Load & Free Memory", targets)
    
    def _create_build_timeline(self, **kwargs) -> TimeSeriesPanel:
        targets = [PanelTarget(
            expr="nestory_build_duration_seconds",
            legend_format="{{scheme}}-{{configuration}}"
        )]
        return TimeSeriesPanel("build_timeline", "Build Performance Timeline", targets, unit="s")
    
    def _create_build_duration_heatmap(self, **kwargs) -> Dict[str, Any]:
        # Heatmap panels need special handling
        return {
            "datasource": {"type": "prometheus", "uid": "PBFA97CFB590B2093"},
            "fieldConfig": {"defaults": {"custom": {"hideFrom": {"legend": False, "tooltip": False, "viz": False}}}},
            "gridPos": {"h": 8, "w": 12, "x": 0, "y": 0},
            "id": hash("build_duration_heatmap") % 10000,
            "options": {
                "calculate": False,
                "cellGap": 1,
                "color": {"mode": "scheme", "scheme": "Spectral"},
                "yAxis": {"unit": "s"}
            },
            "targets": [{
                "expr": "sum by (le) (rate(nestory_build_duration_seconds_bucket[5m]))",
                "format": "heatmap",
                "refId": "A"
            }],
            "title": "Build Duration Heatmap",
            "type": "heatmap"
        }
    
    def _create_response_time_distribution(self, **kwargs) -> TimeSeriesPanel:
        targets = [
            PanelTarget(
                expr="histogram_quantile(0.50, sum by (le) (rate(nestory_http_request_duration_seconds_bucket[5m]))) * 1000",
                legend_format="p50"
            ),
            PanelTarget(
                expr="histogram_quantile(0.95, sum by (le) (rate(nestory_http_request_duration_seconds_bucket[5m]))) * 1000",
                legend_format="p95",
                ref_id="B"
            ),
            PanelTarget(
                expr="histogram_quantile(0.99, sum by (le) (rate(nestory_http_request_duration_seconds_bucket[5m]))) * 1000",
                legend_format="p99",
                ref_id="C"
            )
        ]
        return TimeSeriesPanel("response_time_distribution", "Response Time Distribution", targets, unit="ms")
    
    def _create_cache_hit_ratio(self, **kwargs) -> GaugePanel:
        targets = [PanelTarget(
            expr="100 * sum(rate(nestory_cache_hits_total[5m])) / clamp_min(sum(rate(nestory_cache_requests_total[5m])), 1)",
            legend_format="Cache Hit Ratio"
        )]
        return GaugePanel("cache_hit_ratio", "Cache Hit Ratio", targets)

class DashboardTemplate:
    """Dashboard template with modular components"""
    
    def __init__(self, template_name: str, title: str, description: str = ""):
        self.template_name = template_name
        self.title = title
        self.description = description
        self.sections = []
        self.component_library = ComponentLibrary()
    
    def add_section(self, section_title: str, components: List[Dict[str, Any]]):
        """Add a section with components to the dashboard"""
        self.sections.append({
            "title": section_title,
            "components": components
        })
    
    def generate_dashboard(self, environment: str = "dev") -> Dict[str, Any]:
        """Generate complete dashboard JSON"""
        config_manager = get_config_manager()
        env_config = config_manager.get_environment_config(environment)
        
        # Base dashboard structure
        dashboard = {
            "annotations": {
                "list": [
                    {
                        "builtIn": 1,
                        "datasource": {"type": "grafana", "uid": "-- Grafana --"},
                        "enable": True,
                        "hide": True,
                        "iconColor": "rgba(0, 211, 255, 1)",
                        "name": "Annotations & Alerts",
                        "type": "dashboard"
                    }
                ]
            },
            "description": self.description,
            "editable": True,
            "fiscalYearStartMonth": 0,
            "graphTooltip": 1,
            "links": [
                {
                    "icon": "external",
                    "targetBlank": True,
                    "title": "Prometheus",
                    "type": "link",
                    "url": env_config.get("prometheus_url", "http://localhost:9090")
                }
            ],
            "panels": [],
            "refresh": "30s",
            "schemaVersion": 41,
            "tags": ["monitoring", "nestory", environment],
            "time": {"from": "now-6h", "to": "now"},
            "timezone": "browser",
            "title": f"{self.title} – {environment.title()}",
            "uid": f"nry-{self.template_name}-{environment}",
            "version": 1
        }
        
        # Generate panels from sections
        layout = DashboardLayout()
        panel_id = 1
        
        for section in self.sections:
            # Add section row
            section_row = {
                "collapsed": False,
                "gridPos": asdict(layout.next_position(24, 1)),
                "id": panel_id,
                "panels": [],
                "title": section["title"],
                "type": "row"
            }
            dashboard["panels"].append(section_row)
            panel_id += 1
            
            # Add components in this section
            layout.add_row_break()
            
            for component_config in section["components"]:
                component_name = component_config["name"]
                component_size = component_config.get("size", {"width": 8, "height": 8})
                
                try:
                    component = self.component_library.create_component(component_name)
                    grid_pos = layout.next_position(component_size["width"], component_size["height"])
                    
                    if component_name == "build_duration_heatmap":
                        # Special handling for heatmap
                        panel = self.component_library._create_build_duration_heatmap()
                        panel["gridPos"] = asdict(grid_pos)
                        panel["id"] = panel_id
                    else:
                        panel = component.generate_panel(grid_pos)
                        panel["id"] = panel_id
                    
                    dashboard["panels"].append(panel)
                    panel_id += 1
                    
                except Exception as e:
                    print(f"⚠️ Failed to create component '{component_name}': {e}")
        
        return dashboard

def create_unified_template() -> DashboardTemplate:
    """Create a unified dashboard with all monitoring features consolidated"""
    template = DashboardTemplate(
        "unified",
        "Nestory Unified Monitoring Platform",
        "Complete monitoring solution with AI insights, security, DevEx metrics, cost optimization, and collaboration features"
    )
    
    # Executive Overview & SLOs
    template.add_section("Executive Overview & SLOs", [
        {"name": "system_health_slo", "size": {"width": 4, "height": 4}},
        {"name": "build_success_rate", "size": {"width": 4, "height": 4}},
        {"name": "security_score", "size": {"width": 4, "height": 4}},
        {"name": "cost_efficiency", "size": {"width": 4, "height": 4}},
        {"name": "developer_satisfaction", "size": {"width": 4, "height": 4}},
        {"name": "ai_prediction_accuracy", "size": {"width": 4, "height": 4}}
    ])
    
    # Infrastructure & Performance
    template.add_section("Infrastructure & Performance", [
        {"name": "cpu_memory_usage", "size": {"width": 8, "height": 6}},
        {"name": "system_load", "size": {"width": 8, "height": 6}},
        {"name": "network_throughput", "size": {"width": 8, "height": 6}},
        {"name": "disk_usage", "size": {"width": 12, "height": 4}},
        {"name": "resource_optimization", "size": {"width": 12, "height": 4}}
    ])
    
    # AI-Powered Analytics & Predictions
    template.add_section("AI Analytics & Predictions", [
        {"name": "predictive_alerts", "size": {"width": 8, "height": 6}},
        {"name": "anomaly_detection", "size": {"width": 8, "height": 6}},
        {"name": "capacity_forecasting", "size": {"width": 8, "height": 6}},
        {"name": "failure_prediction", "size": {"width": 12, "height": 4}},
        {"name": "optimization_suggestions", "size": {"width": 12, "height": 4}}
    ])
    
    # Security & Compliance
    template.add_section("Security & Compliance", [
        {"name": "security_events", "size": {"width": 8, "height": 6}},
        {"name": "vulnerability_scan", "size": {"width": 8, "height": 6}},
        {"name": "compliance_status", "size": {"width": 8, "height": 6}},
        {"name": "threat_detection", "size": {"width": 12, "height": 4}},
        {"name": "access_audit", "size": {"width": 12, "height": 4}}
    ])
    
    # Developer Experience (DevEx)
    template.add_section("Developer Experience", [
        {"name": "build_duration_p95", "size": {"width": 6, "height": 4}},
        {"name": "deployment_frequency", "size": {"width": 6, "height": 4}},
        {"name": "lead_time", "size": {"width": 6, "height": 4}},
        {"name": "change_failure_rate", "size": {"width": 6, "height": 4}},
        {"name": "developer_velocity", "size": {"width": 12, "height": 6}},
        {"name": "code_quality_trends", "size": {"width": 12, "height": 6}}
    ])
    
    # Cost Optimization & Intelligence
    template.add_section("Cost Intelligence", [
        {"name": "cost_breakdown", "size": {"width": 8, "height": 6}},
        {"name": "resource_utilization", "size": {"width": 8, "height": 6}},
        {"name": "cost_trends", "size": {"width": 8, "height": 6}},
        {"name": "savings_opportunities", "size": {"width": 12, "height": 4}},
        {"name": "budget_alerts", "size": {"width": 12, "height": 4}}
    ])
    
    # Application Performance & Reliability
    template.add_section("Application Performance", [
        {"name": "response_time_distribution", "size": {"width": 8, "height": 6}},
        {"name": "error_rate", "size": {"width": 8, "height": 6}},
        {"name": "cache_hit_ratio", "size": {"width": 8, "height": 6}},
        {"name": "database_performance", "size": {"width": 12, "height": 4}},
        {"name": "api_health", "size": {"width": 12, "height": 4}}
    ])
    
    # Build & CI/CD Intelligence
    template.add_section("CI/CD Intelligence", [
        {"name": "build_timeline", "size": {"width": 8, "height": 6}},
        {"name": "build_duration_heatmap", "size": {"width": 8, "height": 6}},
        {"name": "pipeline_efficiency", "size": {"width": 8, "height": 6}},
        {"name": "test_coverage_trends", "size": {"width": 12, "height": 4}},
        {"name": "deployment_success", "size": {"width": 12, "height": 4}}
    ])
    
    # Collaboration & ChatOps
    template.add_section("Collaboration & ChatOps", [
        {"name": "incident_response_time", "size": {"width": 8, "height": 6}},
        {"name": "team_communication", "size": {"width": 8, "height": 6}},
        {"name": "knowledge_sharing", "size": {"width": 8, "height": 6}},
        {"name": "on_call_metrics", "size": {"width": 12, "height": 4}},
        {"name": "collaboration_health", "size": {"width": 12, "height": 4}}
    ])
    
    return template

def create_comprehensive_template() -> DashboardTemplate:
    """Create the original comprehensive monitoring dashboard template"""
    template = DashboardTemplate(
        "comprehensive",
        "Nestory Complete Monitoring Platform",
        "Comprehensive monitoring with executive overview, infrastructure, and application metrics"
    )
    
    # Executive Overview Section
    template.add_section("Executive Overview", [
        {"name": "system_health_slo", "size": {"width": 6, "height": 4}},
        {"name": "build_success_rate", "size": {"width": 6, "height": 4}},
        {"name": "build_duration_p95", "size": {"width": 6, "height": 4}},
        {"name": "error_rate", "size": {"width": 6, "height": 4}}
    ])
    
    # Infrastructure Section
    template.add_section("Infrastructure & Performance", [
        {"name": "cpu_memory_usage", "size": {"width": 12, "height": 8}},
        {"name": "system_load", "size": {"width": 12, "height": 8}},
        {"name": "disk_usage", "size": {"width": 24, "height": 4}}
    ])
    
    # Build & CI/CD Section
    template.add_section("Build & CI/CD Performance", [
        {"name": "build_timeline", "size": {"width": 12, "height": 8}},
        {"name": "build_duration_heatmap", "size": {"width": 12, "height": 8}}
    ])
    
    # Application Performance Section
    template.add_section("Application Performance", [
        {"name": "response_time_distribution", "size": {"width": 12, "height": 8}},
        {"name": "cache_hit_ratio", "size": {"width": 12, "height": 8}}
    ])
    
    return template

def create_production_template() -> DashboardTemplate:
    """Create a production-focused monitoring dashboard template"""
    template = DashboardTemplate(
        "production",
        "Nestory Production Monitoring",
        "Production-focused monitoring with SLOs, alerts, and critical metrics"
    )
    
    # Critical SLOs Section
    template.add_section("Service Level Objectives", [
        {"name": "system_health_slo", "size": {"width": 8, "height": 4}},
        {"name": "build_success_rate", "size": {"width": 8, "height": 4}},
        {"name": "error_rate", "size": {"width": 8, "height": 4}}
    ])
    
    # Production Infrastructure Section
    template.add_section("Production Infrastructure", [
        {"name": "cpu_memory_usage", "size": {"width": 12, "height": 6}},
        {"name": "disk_usage", "size": {"width": 12, "height": 6}},
        {"name": "system_load", "size": {"width": 24, "height": 4}}
    ])
    
    # Critical Performance Section  
    template.add_section("Critical Performance Metrics", [
        {"name": "build_duration_p95", "size": {"width": 24, "height": 6}}
    ])
    
    return template

# Command line interface
if __name__ == "__main__":
    import sys
    import argparse
    
    parser = argparse.ArgumentParser(description="Generate modular Grafana dashboards")
    parser.add_argument("--template", choices=["comprehensive", "production", "unified"], default="unified",
                       help="Dashboard template to generate")
    parser.add_argument("--environment", choices=["dev", "staging", "prod"], default="dev",
                       help="Target environment")
    parser.add_argument("--output", type=str, default=None,
                       help="Output file path (default: dashboards/{template}-{env}.json)")
    
    args = parser.parse_args()
    
    # Generate dashboard
    if args.template == "comprehensive":
        template = create_comprehensive_template()
    elif args.template == "production":
        template = create_production_template()
    elif args.template == "unified":
        template = create_unified_template()
    else:
        print(f"Unknown template: {args.template}")
        sys.exit(1)
    
    dashboard_json = template.generate_dashboard(args.environment)
    
    # Determine output path
    if args.output:
        output_path = Path(args.output)
    else:
        output_path = Path(__file__).parent.parent / "dashboards" / f"{args.template}-{args.environment}.json"
    
    # Write dashboard
    output_path.parent.mkdir(exist_ok=True)
    with open(output_path, 'w') as f:
        json.dump(dashboard_json, f, indent=2)
    
    print(f"✅ Generated dashboard: {output_path}")
    print(f"📊 Template: {args.template}")
    print(f"🌍 Environment: {args.environment}")
    print(f"🏷️ UID: {dashboard_json['uid']}")