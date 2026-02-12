#!/usr/bin/env python3
"""
verify_system.py
Intent: Comprehensive system verification before shipping
Checks all components, dependencies, and files
"""

import sys
import os
import subprocess
import platform
from pathlib import Path

# ========== COLORS ==========
BOLD = '\033[1m'
GREEN = '\033[32m'
RED = '\033[31m'
YELLOW = '\033[33m'
CYAN = '\033[36m'
DIM = '\033[2m'
NC = '\033[0m'

class SystemVerifier:
    def __init__(self):
        self.project_root = Path(__file__).parent.parent
        self.passed = 0
        self.failed = 0
        self.warnings = 0
    
    def banner(self):
        print(f'\n{BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}')
        print(f'{BOLD}{CYAN}MatLabC++ System Verification{NC}')
        print(f'{DIM}Pre-ship validation{NC}')
        print(f'{BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}\n')
    
    def section(self, title):
        print(f'\n{BOLD}{CYAN}▶ {title}{NC}')
    
    def check(self, name, condition, optional=False):
        """Check a condition and track results"""
        if condition:
            print(f'  {GREEN}✓{NC} {name}')
            self.passed += 1
            return True
        else:
            if optional:
                print(f'  {YELLOW}!{NC} {name} (optional)')
                self.warnings += 1
            else:
                print(f'  {RED}✗{NC} {name}')
                self.failed += 1
            return False
    
    def verify_python_env(self):
        """Verify Python environment"""
        self.section('Python Environment')
        
        # Python version
        version = sys.version_info
        self.check(
            f'Python {version.major}.{version.minor}.{version.micro}',
            version.major == 3 and version.minor >= 6
        )
        
        # Standard library
        try:
            import subprocess, time, os, sys
            self.check('Standard library imports', True)
        except:
            self.check('Standard library imports', False)
        
        # Optional packages
        for pkg in ['numpy', 'matplotlib']:
            try:
                __import__(pkg)
                self.check(f'{pkg} installed', True, optional=True)
            except:
                self.check(f'{pkg} installed', False, optional=True)
    
    def verify_tools(self):
        """Verify command-line tools"""
        self.section('Command-Line Tools')
        
        tools = {
            'bash': 'Shell scripting',
            'tar': 'Archive creation',
            'zip': 'ZIP compression',
            'base64': 'Encoding',
            'g++': 'C++ compiler',
            'make': 'Build system'
        }
        
        for tool, desc in tools.items():
            optional = tool in ['g++', 'make']
            try:
                result = subprocess.run(
                    ['which', tool],
                    capture_output=True,
                    timeout=2
                )
                self.check(f'{tool} ({desc})', result.returncode == 0, optional)
            except:
                self.check(f'{tool} ({desc})', False, optional)
    
    def verify_structure(self):
        """Verify project structure"""
        self.section('Project Structure')
        
        required_dirs = [
            'demos',
            'scripts',
            'tools',
            'matlab_examples',
            'dist'
        ]
        
        for dir_name in required_dirs:
            path = self.project_root / dir_name
            self.check(f'{dir_name}/ directory', path.exists())
    
    def verify_scripts(self):
        """Verify scripts exist and are executable"""
        self.section('Scripts')
        
        scripts = [
            'scripts/generate_examples_zip.sh',
            'scripts/generate_examples_bundle.sh',
            'scripts/test_bundle_system.sh',
            'scripts/ship_release.sh',
            'demos/run_demo.sh',
            'tools/build_installer.sh'
        ]
        
        for script in scripts:
            path = self.project_root / script
            exists = path.exists()
            executable = exists and os.access(path, os.X_OK)
            
            if exists and executable:
                self.check(f'{script} (executable)', True)
            elif exists:
                self.check(f'{script} (not executable)', False)
            else:
                self.check(f'{script}', False)
    
    def verify_documentation(self):
        """Verify documentation files"""
        self.section('Documentation')
        
        docs = [
            'README.md',
            'FOR_NORMAL_PEOPLE.md',
            'ACTIVE_WINDOW_DEMO.md',
            'MATH_ACCURACY_TESTS.md',
            'MATERIALS_DATABASE.md',
            'EXAMPLES_BUNDLE.md',
            'DISTRIBUTION_COMPARISON.md',
            'scripts/README.md',
            'demos/README.md',
            'tools/INSTALLER.md'
        ]
        
        for doc in docs:
            path = self.project_root / doc
            self.check(f'{doc}', path.exists())
    
    def verify_demos(self):
        """Verify demo files"""
        self.section('Demo Files')
        
        demos = {
            'demos/self_install_demo.py': 'Python self-installer',
            'demos/green_square_demo.cpp': 'C++ demo source',
            'demos/run_demo.sh': 'Demo launcher'
        }
        
        for demo, desc in demos.items():
            path = self.project_root / demo
            self.check(f'{desc}', path.exists())
    
    def verify_examples(self):
        """Verify MATLAB examples"""
        self.section('MATLAB Examples')
        
        examples_dir = self.project_root / 'matlab_examples'
        if examples_dir.exists():
            m_files = list(examples_dir.glob('*.m'))
            self.check(f'{len(m_files)} .m files found', len(m_files) > 0)
            
            # Check specific examples
            required = [
                'basic_demo.m',
                'materials_lookup.m',
                'test_math_accuracy.m'
            ]
            for example in required:
                path = examples_dir / example
                self.check(f'{example}', path.exists())
        else:
            self.check('matlab_examples directory', False)
    
    def verify_bundles(self):
        """Verify distribution bundles"""
        self.section('Distribution Bundles')
        
        dist_dir = self.project_root / 'dist'
        
        bundles = {
            'matlabcpp_examples_v0.3.0.zip': 'ZIP bundle',
            'mlabpp_examples_bundle.sh': 'Shell bundle'
        }
        
        for bundle, desc in bundles.items():
            path = dist_dir / bundle
            if path.exists():
                size_kb = path.stat().st_size // 1024
                self.check(f'{desc} ({size_kb} KB)', True, optional=True)
            else:
                self.check(f'{desc}', False, optional=True)
    
    def verify_permissions(self):
        """Verify file permissions"""
        self.section('File Permissions')
        
        # Scripts should be executable
        script_dirs = ['scripts', 'demos', 'tools']
        executable_count = 0
        
        for dir_name in script_dirs:
            dir_path = self.project_root / dir_name
            if dir_path.exists():
                for script in dir_path.glob('*.sh'):
                    if os.access(script, os.X_OK):
                        executable_count += 1
        
        self.check(f'{executable_count} executable scripts', executable_count > 0)
    
    def summary(self):
        """Show verification summary"""
        total = self.passed + self.failed
        success_rate = (self.passed / total * 100) if total > 0 else 0
        
        print(f'\n{BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}')
        print(f'{BOLD}Verification Summary{NC}')
        print(f'{BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━{NC}\n')
        
        print(f'  {GREEN}Passed:{NC}   {self.passed}')
        print(f'  {RED}Failed:{NC}   {self.failed}')
        print(f'  {YELLOW}Warnings:{NC} {self.warnings}')
        print(f'  {CYAN}Rate:{NC}     {success_rate:.1f}%\n')
        
        if self.failed == 0:
            print(f'{GREEN}{BOLD}✓ System ready to ship{NC}\n')
            return True
        else:
            print(f'{RED}{BOLD}✗ System has issues - fix before shipping{NC}\n')
            return False
    
    def run(self):
        """Run all verifications"""
        self.banner()
        
        self.verify_python_env()
        self.verify_tools()
        self.verify_structure()
        self.verify_scripts()
        self.verify_documentation()
        self.verify_demos()
        self.verify_examples()
        self.verify_bundles()
        self.verify_permissions()
        
        return self.summary()

def main():
    """Main entry point"""
    verifier = SystemVerifier()
    
    try:
        success = verifier.run()
        sys.exit(0 if success else 1)
    except KeyboardInterrupt:
        print(f'\n{YELLOW}Interrupted{NC}')
        sys.exit(130)
    except Exception as e:
        print(f'\n{RED}Error: {e}{NC}')
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__':
    main()
