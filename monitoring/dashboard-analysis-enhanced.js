const { chromium } = require('playwright');
const fs = require('fs');
const path = require('path');

class DashboardAnalyzer {
    constructor(options = {}) {
        this.config = {
            baseUrl: options.baseUrl || 'http://localhost:3000',
            dashboardUrl: '/d/nestory-full/nestory-complete-monitoring-platform',
            credentials: {
                username: 'admin',
                password: 'nestory123'
            },
            timeouts: {
                navigation: 30000,
                selector: 15000,
                analysis: 5000
            },
            screenshots: {
                enabled: true,
                path: options.screenshotPath || '/tmp/dashboard-analysis',
                quality: 90
            },
            analysis: {
                maxPanels: 50,
                scrollDelay: 1500,
                panelLoadWait: 2000
            }
        };
        
        this.results = {
            metadata: {},
            panels: [],
            templateVariables: [],
            performance: {},
            issues: [],
            recommendations: [],
            screenshots: []
        };
        
        this.browser = null;
        this.page = null;
        this.startTime = Date.now();
    }

    async initialize() {
        console.log('🚀 Initializing Enhanced Dashboard Analyzer...\n');
        
        // Ensure screenshot directory exists
        if (this.config.screenshots.enabled) {
            if (!fs.existsSync(this.config.screenshots.path)) {
                fs.mkdirSync(this.config.screenshots.path, { recursive: true });
            }
        }

        this.browser = await chromium.launch({ 
            headless: false, 
            slowMo: 800,
            args: ['--disable-dev-shm-usage', '--no-sandbox']
        });
        
        this.page = await this.browser.newPage();
        await this.page.setViewportSize({ width: 1920, height: 1200 });
        
        // Enhanced error handling
        this.page.on('console', msg => {
            if (msg.type() === 'error') {
                this.addIssue('Console Error', `JavaScript error: ${msg.text()}`, 'high');
            }
        });
        
        this.page.on('requestfailed', request => {
            this.addIssue('Network Error', `Failed request: ${request.url()} - ${request.failure().errorText}`, 'medium');
        });
    }

    async navigateAndAuthenticate() {
        console.log('🌐 Navigating to dashboard...');
        const fullUrl = `${this.config.baseUrl}${this.config.dashboardUrl}`;
        
        try {
            await this.page.goto(fullUrl, { 
                waitUntil: 'networkidle', 
                timeout: this.config.timeouts.navigation 
            });
            
            await this.takeScreenshot('01-initial-navigation');
            
            // Smart login detection with multiple strategies
            const loginSelectors = [
                'input[name="user"]',
                'input[name="username"]', 
                'input[placeholder*="email"]',
                'input[placeholder*="username"]',
                '[data-testid="login-form"] input',
                '.login-form input[type="text"]'
            ];
            
            let loginField = null;
            for (const selector of loginSelectors) {
                try {
                    loginField = await this.page.waitForSelector(selector, { timeout: 3000 });
                    if (loginField) break;
                } catch {}
            }
            
            if (loginField) {
                console.log('🔐 Authenticating...');
                await this.page.fill('input[name="user"], input[name="username"]', this.config.credentials.username);
                await this.page.fill('input[name="password"]', this.config.credentials.password);
                
                // Smart login button detection
                const loginButtons = [
                    'button[type="submit"]',
                    'button:has-text("Log in")',
                    'button:has-text("Login")',
                    'button:has-text("Sign in")',
                    '[data-testid="login-button"]',
                    '.btn-primary'
                ];
                
                for (const btnSelector of loginButtons) {
                    try {
                        await this.page.click(btnSelector);
                        break;
                    } catch {}
                }
                
                await this.page.waitForLoadState('networkidle', { timeout: 10000 });
                await this.takeScreenshot('02-after-authentication');
                console.log('✅ Authentication successful');
            } else {
                console.log('ℹ️  No authentication required');
                await this.takeScreenshot('02-no-auth-needed');
            }
            
            // Capture page metadata
            this.results.metadata = {
                url: this.page.url(),
                title: await this.page.title(),
                timestamp: new Date().toISOString(),
                viewport: await this.page.viewportSize()
            };
            
        } catch (error) {
            this.addIssue('Navigation Error', `Failed to navigate or authenticate: ${error.message}`, 'critical');
            throw error;
        }
    }

    async waitForDashboard() {
        console.log('⏳ Waiting for dashboard to load...');
        
        const dashboardSelectors = [
            '[data-testid="dashboard-container"]',
            '.react-grid-layout',
            '.dashboard-container',
            '[data-testid*="panel"]',
            '.panel-container',
            '.grafana-panel'
        ];
        
        let dashboardFound = false;
        
        for (const selector of dashboardSelectors) {
            try {
                await this.page.waitForSelector(selector, { timeout: this.config.timeouts.selector });
                console.log(`✅ Dashboard detected via: ${selector}`);
                dashboardFound = true;
                break;
            } catch {}
        }
        
        if (!dashboardFound) {
            await this.takeScreenshot('03-dashboard-not-found');
            this.addIssue('Dashboard Loading', 'Dashboard elements not found within timeout', 'critical');
            
            // Debug information
            const currentUrl = this.page.url();
            const pageContent = await this.page.content();
            console.log(`🔍 Current URL: ${currentUrl}`);
            console.log(`🔍 Page contains "panel": ${pageContent.includes('panel')}`);
            console.log(`🔍 Page contains "dashboard": ${pageContent.includes('dashboard')}`);
        } else {
            await this.takeScreenshot('03-dashboard-loaded');
        }
    }

    async comprehensiveScroll() {
        console.log('📜 Performing comprehensive dashboard scroll...');
        
        const { scrollHeight, clientHeight } = await this.page.evaluate(() => ({
            scrollHeight: document.documentElement.scrollHeight,
            clientHeight: document.documentElement.clientHeight
        }));
        
        console.log(`📏 Page height: ${scrollHeight}px, Viewport: ${clientHeight}px`);
        
        if (scrollHeight <= clientHeight) {
            console.log('ℹ️  No scrolling needed - content fits in viewport');
            return;
        }
        
        let screenshots = 0;
        const scrollStep = Math.floor(clientHeight * 0.7); // 70% overlap
        
        for (let position = 0; position < scrollHeight; position += scrollStep) {
            await this.page.evaluate(pos => window.scrollTo({ top: pos, behavior: 'smooth' }), position);
            await this.page.waitForTimeout(this.config.analysis.scrollDelay);
            
            const screenshotName = `04-scroll-${String(screenshots).padStart(2, '0')}-${Math.round(position)}px`;
            await this.takeScreenshot(screenshotName);
            screenshots++;
            
            if (screenshots > 10) break; // Safety limit
        }
        
        // Return to top
        await this.page.evaluate(() => window.scrollTo({ top: 0, behavior: 'smooth' }));
        await this.page.waitForTimeout(1000);
        console.log(`📜 Scroll complete: ${screenshots} screenshots taken`);
    }

    async analyzePanels() {
        console.log('🔍 Starting comprehensive panel analysis...');
        
        // Multiple panel detection strategies
        const panelSelectors = [
            '[data-testid*="panel"]',
            '.panel-container',
            '.grafana-panel',
            '[class*="panel"]',
            '.react-grid-item'
        ];
        
        let allPanels = [];
        
        for (const selector of panelSelectors) {
            try {
                const panels = await this.page.locator(selector).all();
                if (panels.length > 0) {
                    allPanels = panels;
                    console.log(`📊 Found ${panels.length} panels using selector: ${selector}`);
                    break;
                }
            } catch {}
        }
        
        if (allPanels.length === 0) {
            this.addIssue('Panel Detection', 'No panels found on dashboard', 'critical');
            return;
        }
        
        await this.takeScreenshot('05-before-panel-analysis');
        
        const maxPanels = Math.min(allPanels.length, this.config.analysis.maxPanels);
        
        for (let i = 0; i < maxPanels; i++) {
            const panel = allPanels[i];
            console.log(`📊 Analyzing panel ${i + 1}/${maxPanels}...`);
            
            try {
                // Scroll panel into view
                await panel.scrollIntoViewIfNeeded();
                await this.page.waitForTimeout(500);
                
                const panelAnalysis = await this.analyzeIndividualPanel(panel, i + 1);
                this.results.panels.push(panelAnalysis);
                
                // Take screenshot of problematic panels
                if (panelAnalysis.issues.length > 0 || !panelAnalysis.hasData) {
                    const panelBounds = await panel.boundingBox();
                    if (panelBounds) {
                        await this.page.screenshot({
                            path: `${this.config.screenshots.path}/panel-${String(i + 1).padStart(2, '0')}-${panelAnalysis.title.replace(/[^a-zA-Z0-9]/g, '-')}.png`,
                            clip: panelBounds
                        });
                    }
                }
                
            } catch (error) {
                this.addIssue('Panel Analysis', `Failed to analyze panel ${i + 1}: ${error.message}`, 'medium');
            }
        }
        
        console.log(`✅ Panel analysis complete: ${this.results.panels.length} panels analyzed`);
    }

    async analyzeIndividualPanel(panel, index) {
        const analysis = {
            index,
            title: 'Unknown',
            type: 'unknown',
            hasData: false,
            hasError: false,
            isLoading: false,
            performance: {},
            issues: [],
            elements: {}
        };
        
        try {
            // Extract panel title with multiple strategies
            const titleSelectors = [
                '.panel-title',
                '[data-testid="panel-title"]',
                'h3', 'h2', 'h1',
                '.panel-header-title',
                '[class*="title"]'
            ];
            
            for (const selector of titleSelectors) {
                try {
                    const titleElement = panel.locator(selector).first();
                    if (await titleElement.isVisible()) {
                        analysis.title = await titleElement.textContent() || `Panel ${index}`;
                        break;
                    }
                } catch {}
            }
            
            // Detect panel type
            analysis.type = await this.detectPanelType(panel);
            
            // Check for errors
            const errorSelectors = [
                '.panel-status-message',
                '.alert-error', 
                '[data-testid="panel-error"]',
                '.error-message',
                '[class*="error"]'
            ];
            
            for (const selector of errorSelectors) {
                try {
                    const errorElement = panel.locator(selector);
                    if (await errorElement.isVisible()) {
                        analysis.hasError = true;
                        const errorText = await errorElement.textContent();
                        analysis.issues.push(`Error: ${errorText}`);
                    }
                } catch {}
            }
            
            // Check for loading state
            const loadingSelectors = [
                '.panel-loading',
                '.loading',
                '[data-testid="panel-loading"]',
                '.spinner',
                '[class*="loading"]'
            ];
            
            for (const selector of loadingSelectors) {
                try {
                    if (await panel.locator(selector).isVisible()) {
                        analysis.isLoading = true;
                        break;
                    }
                } catch {}
            }
            
            // Check for data presence
            analysis.hasData = await this.checkPanelHasData(panel);
            
            // Performance analysis
            analysis.performance = await this.analyzePanelPerformance(panel);
            
            // Accessibility check
            await this.checkPanelAccessibility(panel, analysis);
            
        } catch (error) {
            analysis.issues.push(`Analysis failed: ${error.message}`);
        }
        
        return analysis;
    }

    async detectPanelType(panel) {
        const typeIndicators = {
            'graph': ['svg', 'canvas', '.flot-base', '.uplot'],
            'stat': ['.stat-panel-value', '.singlestat-panel'],
            'gauge': ['.gauge', 'svg[class*="gauge"]'],
            'table': ['table', '.table-panel'],
            'text': ['.text-panel', '.markdown'],
            'heatmap': ['.heatmap'],
            'logs': ['.logs-panel', '.log-row']
        };
        
        for (const [type, selectors] of Object.entries(typeIndicators)) {
            for (const selector of selectors) {
                try {
                    if (await panel.locator(selector).isVisible()) {
                        return type;
                    }
                } catch {}
            }
        }
        
        return 'unknown';
    }

    async checkPanelHasData(panel) {
        const dataIndicators = [
            'svg path', 'svg rect', 'svg circle', // SVG elements
            'canvas',                              // Canvas elements
            '.flot-base',                         // Flot charts
            '.uplot',                             // UPlot charts
            '.stat-panel-value',                  // Stat panels
            'table tbody tr',                     // Table rows
            '.log-row'                            // Log entries
        ];
        
        for (const selector of dataIndicators) {
            try {
                const elements = await panel.locator(selector).all();
                if (elements.length > 0) {
                    return true;
                }
            } catch {}
        }
        
        // Check for "No data" messages
        const noDataIndicators = [
            ':has-text("No data")',
            ':has-text("No data points")',
            ':has-text("N/A")',
            '.empty-state'
        ];
        
        for (const selector of noDataIndicators) {
            try {
                if (await panel.locator(selector).isVisible()) {
                    return false;
                }
            } catch {}
        }
        
        return false;
    }

    async analyzePanelPerformance(panel) {
        const startTime = Date.now();
        
        try {
            // Wait for panel to be stable (no layout changes)
            await panel.waitForElementState('stable', { timeout: 2000 });
            const stabilityTime = Date.now() - startTime;
            
            return {
                stabilityTime,
                isStable: stabilityTime < 5000
            };
        } catch {
            return {
                stabilityTime: Date.now() - startTime,
                isStable: false
            };
        }
    }

    async checkPanelAccessibility(panel, analysis) {
        // Check for ARIA labels
        try {
            const hasAriaLabel = await panel.getAttribute('aria-label');
            if (!hasAriaLabel) {
                analysis.issues.push('Missing ARIA label');
            }
        } catch {}
        
        // Check for proper headings
        const headings = await panel.locator('h1, h2, h3, h4, h5, h6').count();
        if (headings === 0 && analysis.title === 'Unknown') {
            analysis.issues.push('No proper heading structure');
        }
    }

    async analyzeTemplateVariables() {
        console.log('🎛️  Analyzing template variables...');
        
        const variableSelectors = [
            '[data-testid*="variable"]',
            '.template-variable',
            '.variable-option',
            '[class*="template"]',
            '.gf-form-select-wrapper'
        ];
        
        let variables = [];
        
        for (const selector of variableSelectors) {
            try {
                const foundVars = await this.page.locator(selector).all();
                if (foundVars.length > 0) {
                    variables = foundVars;
                    break;
                }
            } catch {}
        }
        
        console.log(`🎛️  Found ${variables.length} template variables`);
        
        for (let i = 0; i < variables.length; i++) {
            const variable = variables[i];
            try {
                const varAnalysis = {
                    index: i + 1,
                    name: 'Unknown',
                    isInteractive: false,
                    hasOptions: false
                };
                
                varAnalysis.name = await variable.textContent() || `Variable ${i + 1}`;
                varAnalysis.isInteractive = await variable.isEnabled();
                
                this.results.templateVariables.push(varAnalysis);
            } catch (error) {
                this.addIssue('Template Variable', `Failed to analyze variable ${i + 1}: ${error.message}`, 'low');
            }
        }
    }

    async analyzePerformance() {
        console.log('⚡ Analyzing performance metrics...');
        
        try {
            const performanceData = await this.page.evaluate(() => {
                const navigation = performance.getEntriesByType('navigation')[0];
                return {
                    loadTime: navigation ? navigation.loadEventEnd - navigation.loadEventStart : 0,
                    domContentLoaded: navigation ? navigation.domContentLoadedEventEnd - navigation.domContentLoadedEventStart : 0,
                    resourceCount: performance.getEntriesByType('resource').length,
                    memoryUsage: performance.memory ? performance.memory.usedJSHeapSize : null
                };
            });
            
            this.results.performance = {
                ...performanceData,
                analysisTime: Date.now() - this.startTime
            };
            
            // Performance recommendations
            if (performanceData.loadTime > 5000) {
                this.addRecommendation('Performance', 'Consider optimizing dashboard load time (>5s)', 'medium');
            }
            
            if (performanceData.resourceCount > 100) {
                this.addRecommendation('Performance', 'High number of resources loaded - consider optimization', 'low');
            }
            
        } catch (error) {
            this.addIssue('Performance Analysis', `Failed to gather performance metrics: ${error.message}`, 'low');
        }
    }

    async takeScreenshot(name) {
        if (!this.config.screenshots.enabled) return;
        
        try {
            const filename = `${name}.png`;
            const fullPath = path.join(this.config.screenshots.path, filename);
            
            await this.page.screenshot({
                path: fullPath,
                quality: this.config.screenshots.quality,
                fullPage: false
            });
            
            this.results.screenshots.push({
                name: filename,
                path: fullPath,
                timestamp: new Date().toISOString()
            });
            
            console.log(`📸 Screenshot: ${filename}`);
        } catch (error) {
            console.log(`⚠️  Screenshot failed: ${error.message}`);
        }
    }

    addIssue(category, message, severity = 'medium') {
        this.results.issues.push({
            category,
            message,
            severity,
            timestamp: new Date().toISOString()
        });
    }

    addRecommendation(category, message, priority = 'medium') {
        this.results.recommendations.push({
            category,
            message,
            priority,
            timestamp: new Date().toISOString()
        });
    }

    generateReport() {
        console.log('\n' + '='.repeat(80));
        console.log('📋 ENHANCED DASHBOARD ANALYSIS REPORT');
        console.log('='.repeat(80));
        
        // Dashboard Overview
        console.log('\n🌐 DASHBOARD OVERVIEW');
        console.log(`   📄 Title: ${this.results.metadata.title}`);
        console.log(`   🔗 URL: ${this.results.metadata.url}`);
        console.log(`   🖥️  Viewport: ${this.results.metadata.viewport.width}x${this.results.metadata.viewport.height}`);
        console.log(`   ⏱️  Analysis Time: ${Math.round(this.results.performance.analysisTime / 1000)}s`);
        
        // Panel Summary
        console.log(`\n📊 PANEL ANALYSIS (${this.results.panels.length} panels)`);
        const panelsWithData = this.results.panels.filter(p => p.hasData).length;
        const panelsWithErrors = this.results.panels.filter(p => p.hasError).length;
        const panelsLoading = this.results.panels.filter(p => p.isLoading).length;
        
        console.log(`   ✅ Panels with data: ${panelsWithData}/${this.results.panels.length} (${Math.round(panelsWithData/this.results.panels.length*100)}%)`);
        console.log(`   ❌ Panels with errors: ${panelsWithErrors}/${this.results.panels.length}`);
        console.log(`   ⏳ Panels loading: ${panelsLoading}/${this.results.panels.length}`);
        
        // Panel Type Breakdown
        const panelTypes = {};
        this.results.panels.forEach(p => {
            panelTypes[p.type] = (panelTypes[p.type] || 0) + 1;
        });
        console.log('\n📊 PANEL TYPES:');
        Object.entries(panelTypes).forEach(([type, count]) => {
            console.log(`   📈 ${type}: ${count}`);
        });
        
        // Template Variables
        console.log(`\n🎛️  TEMPLATE VARIABLES (${this.results.templateVariables.length} found)`);
        const functionalVars = this.results.templateVariables.filter(v => v.isInteractive).length;
        console.log(`   ✅ Interactive: ${functionalVars}/${this.results.templateVariables.length}`);
        
        // Performance Metrics
        console.log('\n⚡ PERFORMANCE METRICS');
        console.log(`   📈 Load time: ${this.results.performance.loadTime}ms`);
        console.log(`   🏃 DOM ready: ${this.results.performance.domContentLoaded}ms`);
        console.log(`   📦 Resources: ${this.results.performance.resourceCount}`);
        if (this.results.performance.memoryUsage) {
            console.log(`   🧠 Memory: ${Math.round(this.results.performance.memoryUsage / 1024 / 1024)}MB`);
        }
        
        // Issues by Severity
        const issuesBySeverity = {};
        this.results.issues.forEach(issue => {
            issuesBySeverity[issue.severity] = (issuesBySeverity[issue.severity] || 0) + 1;
        });
        
        console.log('\n⚠️  ISSUES BY SEVERITY');
        Object.entries(issuesBySeverity).forEach(([severity, count]) => {
            const icon = severity === 'critical' ? '🚨' : severity === 'high' ? '⚠️' : severity === 'medium' ? '💡' : 'ℹ️';
            console.log(`   ${icon} ${severity.toUpperCase()}: ${count}`);
        });
        
        // Detailed Issues
        if (this.results.issues.length > 0) {
            console.log('\n🔍 DETAILED ISSUES:');
            this.results.issues.forEach((issue, index) => {
                const icon = issue.severity === 'critical' ? '🚨' : issue.severity === 'high' ? '⚠️' : '💡';
                console.log(`${index + 1}. ${icon} [${issue.category}] ${issue.message}`);
            });
        }
        
        // Recommendations
        if (this.results.recommendations.length > 0) {
            console.log('\n💡 RECOMMENDATIONS:');
            this.results.recommendations.forEach((rec, index) => {
                const icon = rec.priority === 'high' ? '🔥' : rec.priority === 'medium' ? '💡' : 'ℹ️';
                console.log(`${index + 1}. ${icon} [${rec.category}] ${rec.message}`);
            });
        }
        
        // Screenshots
        if (this.results.screenshots.length > 0) {
            console.log(`\n📸 SCREENSHOTS (${this.results.screenshots.length} captured)`);
            console.log(`   📁 Location: ${this.config.screenshots.path}`);
            console.log('   📝 Files:');
            this.results.screenshots.forEach(screenshot => {
                console.log(`      - ${screenshot.name}`);
            });
        }
        
        console.log('\n' + '='.repeat(80));
        console.log('✅ Enhanced analysis complete!');
        console.log('='.repeat(80));
        
        // Save detailed JSON report
        this.saveJsonReport();
    }

    saveJsonReport() {
        try {
            const reportPath = path.join(this.config.screenshots.path, 'dashboard-analysis-report.json');
            fs.writeFileSync(reportPath, JSON.stringify(this.results, null, 2));
            console.log(`📄 Detailed report saved: ${reportPath}`);
        } catch (error) {
            console.log(`⚠️  Failed to save JSON report: ${error.message}`);
        }
    }

    async cleanup() {
        if (this.browser) {
            await this.browser.close();
        }
    }

    async run() {
        try {
            await this.initialize();
            await this.navigateAndAuthenticate();
            await this.waitForDashboard();
            await this.comprehensiveScroll();
            await this.analyzePanels();
            await this.analyzeTemplateVariables();
            await this.analyzePerformance();
            this.generateReport();
        } catch (error) {
            console.error('🚨 Analysis failed:', error);
            this.addIssue('System', `Analysis failed: ${error.message}`, 'critical');
            this.generateReport();
        } finally {
            await this.cleanup();
        }
    }
}

// Run the enhanced analyzer
const analyzer = new DashboardAnalyzer({
    screenshotPath: '/tmp/dashboard-analysis-enhanced'
});

analyzer.run().catch(console.error);