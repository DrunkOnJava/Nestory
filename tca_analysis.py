#!/usr/bin/env python3
"""
TCA Architecture Analysis for Nestory
Analyzes The Composable Architecture relationships and dependencies
"""

import os
import re
import json
from collections import defaultdict, Counter
from pathlib import Path

def find_swift_files(directory):
    """Find all Swift files in directory"""
    return list(Path(directory).rglob("*.swift"))

def extract_tca_elements(file_path):
    """Extract TCA elements from a Swift file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
    except:
        return {}
    
    elements = {}
    
    # Find @Reducer structs
    reducer_pattern = r'@Reducer\s+(?:struct|class|enum)\s+(\w+)'
    reducers = re.findall(reducer_pattern, content)
    if reducers:
        elements['reducers'] = reducers
    
    # Find @ObservableState structs
    state_pattern = r'@ObservableState\s+struct\s+(\w+)'
    states = re.findall(state_pattern, content)
    if states:
        elements['states'] = states
    
    # Find @Dependency declarations
    dependency_pattern = r'@Dependency\(\\\.(\w+)\)\s+var\s+(\w+)'
    dependencies = re.findall(dependency_pattern, content)
    if dependencies:
        elements['dependencies'] = dependencies
    
    # Find Action enums
    action_pattern = r'enum\s+Action[^{]*{([^}]*(?:{[^}]*}[^}]*)*[^}]*)}*'
    actions = re.findall(action_pattern, content, re.DOTALL)
    if actions:
        # Count action cases
        action_cases = []
        for action in actions:
            cases = re.findall(r'case\s+(\w+)', action)
            action_cases.extend(cases)
        elements['action_cases'] = action_cases
    
    # Find imports
    import_pattern = r'import\s+(\w+)'
    imports = re.findall(import_pattern, content)
    if imports:
        elements['imports'] = imports
    
    return elements

def analyze_architecture():
    """Analyze TCA architecture in the project"""
    
    print("🧩 TCA Architecture Analysis")
    print("=" * 50)
    
    # Directory structure
    directories = {
        'Features': 'Features/',
        'App-Main': 'App-Main/',
        'Services': 'Services/',
        'UI': 'UI/',
        'Infrastructure': 'Infrastructure/',
        'Foundation': 'Foundation/'
    }
    
    all_elements = defaultdict(list)
    layer_stats = defaultdict(int)
    dependency_graph = defaultdict(set)
    
    # Analyze each layer
    for layer_name, directory in directories.items():
        if not os.path.exists(directory):
            continue
            
        print(f"\n📁 {layer_name} Layer:")
        print("-" * 30)
        
        swift_files = find_swift_files(directory)
        layer_stats[f'{layer_name}_files'] = len(swift_files)
        
        layer_elements = {
            'reducers': [],
            'states': [],
            'dependencies': [],
            'action_cases': [],
            'imports': []
        }
        
        for file_path in swift_files:
            elements = extract_tca_elements(file_path)
            
            for key in layer_elements:
                if key in elements:
                    layer_elements[key].extend(elements[key])
                    all_elements[key].extend([(layer_name, item) for item in elements[key]])
            
            # Track dependencies for graph
            if 'dependencies' in elements:
                relative_path = str(file_path).replace(os.getcwd() + '/', '')
                for dep_key, dep_var in elements['dependencies']:
                    dependency_graph[relative_path].add(f"{dep_key}.{dep_var}")
        
        # Print layer summary
        if layer_elements['reducers']:
            print(f"  🔄 Reducers: {', '.join(layer_elements['reducers'])}")
        if layer_elements['states']:
            print(f"  📊 States: {', '.join(layer_elements['states'])}")
        if layer_elements['dependencies']:
            deps = [f"{k}.{v}" for k, v in layer_elements['dependencies']]
            print(f"  🔗 Dependencies: {', '.join(deps)}")
        if layer_elements['action_cases']:
            print(f"  ⚡ Action Cases: {len(layer_elements['action_cases'])}")
        
        print(f"  📄 Swift Files: {len(swift_files)}")
    
    # Overall statistics
    print(f"\n📈 Overall TCA Statistics:")
    print("-" * 30)
    
    reducer_count = len([x for x in all_elements['reducers']])
    state_count = len([x for x in all_elements['states']])
    dependency_count = len([x for x in all_elements['dependencies']])
    action_count = len([x for x in all_elements['action_cases']])
    
    print(f"Total Reducers: {reducer_count}")
    print(f"Total States: {state_count}")
    print(f"Total Dependencies: {dependency_count}")
    print(f"Total Action Cases: {action_count}")
    
    # Dependency analysis
    print(f"\n🔗 Dependency Graph:")
    print("-" * 30)
    
    dependency_usage = Counter()
    for file_path, deps in dependency_graph.items():
        layer = file_path.split('/')[0] if '/' in file_path else 'Root'
        print(f"{layer}/{os.path.basename(file_path)}:")
        for dep in sorted(deps):
            print(f"  • {dep}")
            dependency_usage[dep] += 1
    
    print(f"\n🏆 Most Used Dependencies:")
    print("-" * 30)
    for dep, count in dependency_usage.most_common(10):
        print(f"  {dep}: {count} usages")
    
    # Architecture compliance
    print(f"\n✅ Architecture Compliance:")
    print("-" * 30)
    
    features_with_reducers = len([x for layer, x in all_elements['reducers'] if layer == 'Features'])
    app_main_with_dependencies = len([x for layer, x in all_elements['dependencies'] if layer == 'App-Main'])
    
    print(f"Features with Reducers: {features_with_reducers}")
    print(f"App-Main with Dependencies: {app_main_with_dependencies}")
    
    if features_with_reducers > 0:
        print("✅ TCA Reducers are properly located in Features layer")
    else:
        print("⚠️  No TCA Reducers found in Features layer")
    
    if app_main_with_dependencies > 0:
        print("✅ App-Main layer uses dependency injection")
    else:
        print("⚠️  App-Main layer might not be using dependency injection")

if __name__ == "__main__":
    try:
        analyze_architecture()
    except KeyboardInterrupt:
        print("\n\n🛑 Analysis interrupted")
    except Exception as e:
        print(f"\n❌ Error during analysis: {e}")
        import traceback
        traceback.print_exc()