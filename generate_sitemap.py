#!/usr/bin/env python3
"""
Sitemap Generator for Hermann Bahr Textverzeichnis
Generates sitemap.xml from HTML files in the html/ directory
"""

import os
from datetime import datetime
from pathlib import Path
import xml.etree.ElementTree as ET

# Configuration
BASE_URL = "https://bahr-textverzeichnis.acdh.oeaw.ac.at"
HTML_DIR = "html"
OUTPUT_FILE = "html/sitemap.xml"

# Priority settings
PRIORITY_MAP = {
    "index.html": "1.0",
    "toc.html": "0.9",
    "tocs.html": "0.9",
    "bibliografie.html": "0.9",
    "listperson.html": "0.8",
    "search.html": "0.7",
    "calendar.html": "0.7",
    "imprint.html": "0.3",
}

# Default priorities by pattern
DEFAULT_PRIORITY = "0.6"
EDITION_PRIORITY = "0.8"

# Exclude patterns
EXCLUDE_PATTERNS = [
    "xml-view",
    "beacon.txt",
]


def should_exclude(filepath):
    """Check if a file should be excluded from sitemap"""
    filepath_str = str(filepath)
    return any(pattern in filepath_str for pattern in EXCLUDE_PATTERNS)


def get_priority(filename):
    """Determine priority based on filename"""
    if filename in PRIORITY_MAP:
        return PRIORITY_MAP[filename]
    # Edition files typically match pattern like L041xxx.html, HBxxx.html, A00xxxx.html
    if any(filename.startswith(prefix) for prefix in ["L0", "HB", "A0", "pmb"]):
        return EDITION_PRIORITY
    return DEFAULT_PRIORITY


def get_lastmod(filepath):
    """Get last modification date of a file"""
    try:
        mtime = os.path.getmtime(filepath)
        return datetime.fromtimestamp(mtime).strftime("%Y-%m-%d")
    except Exception:
        return datetime.now().strftime("%Y-%m-%d")


def generate_sitemap():
    """Generate sitemap.xml from HTML files"""

    # Create root element with namespace
    urlset = ET.Element("urlset")
    urlset.set("xmlns", "http://www.sitemaps.org/schemas/sitemap/0.9")

    html_path = Path(HTML_DIR)

    if not html_path.exists():
        print(f"Error: Directory {HTML_DIR} does not exist")
        return

    # Collect all HTML files
    html_files = []
    for html_file in html_path.rglob("*.html"):
        if not should_exclude(html_file):
            html_files.append(html_file)

    # Sort for consistent output
    html_files.sort()

    print(f"Found {len(html_files)} HTML files")

    # Add URLs to sitemap
    for html_file in html_files:
        # Get relative path from html directory
        rel_path = html_file.relative_to(html_path)

        # Create URL element
        url = ET.SubElement(urlset, "url")

        # Add loc (location/URL)
        loc = ET.SubElement(url, "loc")
        loc.text = f"{BASE_URL}/{rel_path}"

        # Add lastmod (last modification date)
        lastmod = ET.SubElement(url, "lastmod")
        lastmod.text = get_lastmod(html_file)

        # Add priority
        priority = ET.SubElement(url, "priority")
        priority.text = get_priority(html_file.name)

        # Add changefreq
        changefreq = ET.SubElement(url, "changefreq")
        if html_file.name == "index.html":
            changefreq.text = "weekly"
        elif html_file.name in ["toc.html", "tocs.html", "bibliografie.html", "calendar.html"]:
            changefreq.text = "weekly"
        elif html_file.name == "search.html":
            changefreq.text = "daily"
        else:
            changefreq.text = "monthly"

    # Create XML tree and write to file
    tree = ET.ElementTree(urlset)
    ET.indent(tree, space="  ")  # Pretty print (Python 3.9+)

    try:
        tree.write(OUTPUT_FILE, encoding="utf-8", xml_declaration=True)
        print(f"✓ Sitemap generated successfully: {OUTPUT_FILE}")
        print(f"  Total URLs: {len(html_files)}")
    except Exception as e:
        print(f"Error writing sitemap: {e}")


if __name__ == "__main__":
    generate_sitemap()
