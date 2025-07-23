#!/usr/bin/env python3
"""
Script to extract AWS glossary terms and update cspell dictionary.

This script:
1. Fetches the AWS glossary page
2. Extracts terms from <dt> tags
3. Filters for single words not in cspell's global dictionary
4. Adds missing words to .github/cspell.json
"""

import json
import re
import subprocess
import sys
from pathlib import Path
from typing import List, Set
import requests
from bs4 import BeautifulSoup


def fetch_aws_glossary_terms() -> List[str]:
    """Fetch and extract terms from AWS glossary page."""
    url = "https://docs.aws.amazon.com/glossary/latest/reference/glos-chap.html"
    
    try:
        response = requests.get(url, timeout=30)
        response.raise_for_status()
    except requests.RequestException as e:
        print(f"Error fetching AWS glossary: {e}")
        sys.exit(1)
    
    soup = BeautifulSoup(response.content, 'html.parser')
    dt_tags = soup.find_all('dt')
    
    terms = []
    for dt in dt_tags:
        # Extract text and clean it
        text = dt.get_text(strip=True)
        if text:
            terms.append(text)
    
    print(f"Found {len(terms)} terms from AWS glossary")
    return terms


def extract_single_words(terms: List[str]) -> Set[str]:
    """Extract single words from terms, filtering out common patterns."""
    single_words = set()
    
    for term in terms:
        # Split on whitespace and common separators
        words = re.split(r'[\s\-_/()]+', term.lower())
        
        for word in words:
            # Clean word of punctuation and validate
            clean_word = re.sub(r'[^\w]', '', word)
            
            # Only include words that are:
            # - At least 2 characters long
            # - Contain letters (not just numbers)
            # - Not common English words we want to skip
            if (len(clean_word) >= 2 and 
                re.search(r'[a-zA-Z]', clean_word) and
                not clean_word.isdigit()):
                single_words.add(clean_word.lower())
    
    return single_words


def check_cspell_dictionary(words: Set[str]) -> Set[str]:
    """Check which words are not in cspell's global dictionary."""
    missing_words = set()
    
    # Create a temporary file with the words to check
    temp_file = Path("temp_words_check.txt")
    try:
        with open(temp_file, 'w') as f:
            f.write('\n'.join(words))
        
        # Run cspell to check the words
        result = subprocess.run([
            'cspell', 'lint', '--no-summary', '--no-progress', '--no-color', '--words-only', '-c', '.github/cspell.json', str(temp_file)
        ], capture_output=True, text=True)

        # Parse cspell output to find misspelled words
        if result.stdout:
            lines = result.stdout.strip().split('\n')
            for line in lines:
                missing_words.add(line)
    
    except subprocess.CalledProcessError as e:
        print(f"Error running cspell: {e}")
        # Fallback: assume all words are missing if cspell fails
        missing_words = words
    except FileNotFoundError:
        print("cspell not found. Please install it with: npm install -g cspell")
        sys.exit(1)
    finally:
        # Clean up temp file
        if temp_file.exists():
            temp_file.unlink()
        pass
    
    return missing_words


def update_cspell_config(new_words: Set[str]) -> None:
    """Update .github/cspell.json with new words."""
    cspell_path = Path(".github/cspell.json")
    try:
        with open(cspell_path, 'r') as f:
            config = json.load(f)
    except Exception as e:
        print(f"Could not load or parse {cspell_path} ({e})- aborting.")
        exit(1)
    
    # Add new words, avoiding duplicates
    existing_words = set(config['words'])
    words_to_add = new_words - existing_words

    if words_to_add:
        config['words'].extend(sorted(words_to_add))
        config['words'].sort()  # Keep the list sorted
        
        # Write updated config
        with open(cspell_path, 'w') as f:
            json.dump(config, f, indent=2, sort_keys=True)
        
        print(f"Added {len(words_to_add)} new words to {cspell_path}")
        print("New words:", ', '.join(sorted(words_to_add)))
    else:
        print("No new words to add to cspell dictionary")


def main():
    """Main function to orchestrate the process."""
    print("Fetching AWS glossary terms...")
    terms = fetch_aws_glossary_terms()
    
    print("Extracting single words...")
    single_words = extract_single_words(terms)
    print(f"Extracted {len(single_words)} unique single words")
    
    print("Checking against cspell dictionary...")
    missing_words = check_cspell_dictionary(single_words)
    print(f"Found {len(missing_words)} words not in cspell dictionary")

    if missing_words:
        print("They are:")
        for word in missing_words:
            print(word)
        response = input("Do you wish to update .github/cspell.json with these new words? (y/N) ").strip().lower()
        if response == 'y':
            print("Updating cspell configuration...")
            update_cspell_config(missing_words)
    
    print("Process completed successfully!")


if __name__ == "__main__":
    main()
