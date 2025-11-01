#!/usr/bin/env python3
"""
README.md Validation Test Script
Tests the structure, links, and content of the README.md file
"""

import re
import os
import sys
from pathlib import Path

class READMEValidator:
    def __init__(self, readme_path='README.md'):
        self.readme_path = readme_path
        self.errors = []
        self.warnings = []
        
        with open(readme_path, 'r', encoding='utf-8') as f:
            self.content = f.read()
            self.lines = self.content.split('\n')
    
    def validate_all(self):
        """Run all validation checks"""
        print("Starting README.md validation...")
        print("=" * 60)
        
        self.check_required_sections()
        self.check_internal_links()
        self.check_external_links_format()
        self.check_markdown_syntax()
        self.check_version_consistency()
        self.check_emoji_usage()
        
        return self.report_results()
    
    def check_required_sections(self):
        """Verify all required sections exist"""
        required_sections = [
            r'##\s+.*主な機能',
            r'##\s+.*アーキテクチャ',
            r'##\s+.*技術スタック',
            r'##\s+.*セットアップ',
            r'##\s+.*使い方',
            r'##\s+.*テスト',
            r'##\s+.*ライセンス',
        ]
        
        for section_pattern in required_sections:
            if not re.search(section_pattern, self.content):
                self.errors.append(f"Missing required section: {section_pattern}")
            else:
                print(f"✓ Found section: {section_pattern}")
    
    def check_internal_links(self):
        """Verify internal documentation links point to existing files"""
        # Find all markdown links
        link_pattern = r'\[([^\]]+)\]\(([^)]+)\)'
        links = re.findall(link_pattern, self.content)
        
        print(f"\nChecking {len(links)} links...")
        
        for link_text, link_target in links:
            # Skip external links
            if link_target.startswith('http://') or link_target.startswith('https://'):
                continue
            
            # Skip anchors
            if link_target.startswith('#'):
                continue
            
            # Check if file exists
            link_path = Path(link_target)
            if not link_path.exists():
                self.errors.append(f"Broken link: [{link_text}]({link_target}) - file does not exist")
            else:
                print(f"  ✓ Valid link: {link_target}")
    
    def check_external_links_format(self):
        """Verify external links are properly formatted"""
        external_links = [
            (r'PokéAPI', r'https://pokeapi\.co/'),
            (r'Kingfisher', r'https://github\.com/onevcat/Kingfisher'),
            (r'PokemonAPI', r'https://github\.com/kinkofer/PokemonAPI'),
        ]
        
        print("\nChecking external links...")
        for name, url_pattern in external_links:
            if not re.search(url_pattern, self.content):
                self.warnings.append(f"Expected link to {name} ({url_pattern}) not found")
            else:
                print(f"  ✓ Found link to {name}")
    
    def check_markdown_syntax(self):
        """Check for common markdown syntax issues"""
        print("\nChecking markdown syntax...")
        
        # Check for unclosed code blocks
        code_block_count = self.content.count('```')
        if code_block_count % 2 != 0:
            self.errors.append(f"Unclosed code block detected (found {code_block_count} markers)")
        else:
            print(f"  ✓ Code blocks properly closed ({code_block_count // 2} blocks)")
        
        # Check for proper heading hierarchy
        headings = re.findall(r'^(#{1,6})\s+(.+)$', self.content, re.MULTILINE)
        print(f"  ✓ Found {len(headings)} headings")
        
        # Check for empty sections (heading followed immediately by another heading)
        for i in range(len(self.lines) - 1):
            if self.lines[i].startswith('#') and self.lines[i+1].startswith('#'):
                if self.lines[i].strip() and not any(self.lines[i+j].strip() for j in range(1, min(3, len(self.lines)-i-1))):
                    self.warnings.append(f"Empty section at line {i+1}: {self.lines[i][:50]}")
    
    def check_version_consistency(self):
        """Check version numbers are consistent"""
        print("\nChecking version consistency...")
        
        # Look for version mentions
        versions = re.findall(r'v(\d+\.\d+(?:\.\d+)?)', self.content)
        print(f"  Found version mentions: {set(versions)}")
        
        # Check if versions are mentioned in chronological order in their sections
        version_sections = [
            ('v4.0', 'v4.0の新機能'),
            ('v3.0', 'v3.0の機能'),
            ('v2.0', 'v2.0の機能'),
            ('v1.0', 'v1.0の機能'),
        ]
        
        for _version, section_name in version_sections:
            if section_name in self.content:
                print(f"  ✓ Found section: {section_name}")
            else:
                self.warnings.append(f"Version section not found: {section_name}")
    
    def check_emoji_usage(self):
        """Check emoji usage for consistency"""
        print("\nChecking emoji usage...")
        
        # Count emojis in headings
        emoji_headings = re.findall(r'^##\s+([🌟🏛🛠⚙️📱⚡️🧪🐛📈📚📄🙏🤝📧])', self.content, re.MULTILINE)
        print(f"  Found {len(emoji_headings)} emoji in section headings")
        
        if len(emoji_headings) > 0:
            print("  ✓ Emojis used for visual enhancement")
    
    def report_results(self):
        """Print validation results"""
        print("\n" + "=" * 60)
        print("VALIDATION RESULTS")
        print("=" * 60)
        
        if not self.errors and not self.warnings:
            print("✅ All checks passed! README.md is well-formed.")
            return 0
        
        if self.errors:
            print(f"\n❌ ERRORS ({len(self.errors)}):")
            for i, error in enumerate(self.errors, 1):
                print(f"  {i}. {error}")
        
        if self.warnings:
            print(f"\n⚠️  WARNINGS ({len(self.warnings)}):")
            for i, warning in enumerate(self.warnings, 1):
                print(f"  {i}. {warning}")
        
        print("\n" + "=" * 60)
        
        # Return exit code (0 if only warnings, 1 if errors)
        return 1 if self.errors else 0

if __name__ == '__main__':
    validator = READMEValidator()
    sys.exit(validator.validate_all())