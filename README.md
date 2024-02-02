# Subtitle Cleanup and Renumbering Utility

This utility script is designed to automate the cleanup and renumbering of subtitle files (SRT format), making it easier to maintain clean and correctly sequenced subtitles for your video content.

## Features
This script offers a range of features to improve the quality of subtitle files:
- **Automatic Advertisement Removal**: Detects and removes text blocks that contain advertisements, sponsor messages, or irrelevant information not part of the actual subtitles.
- **Punctuation and Spacing Correction**: Fixes common issues with punctuation and spacing, ensuring that subtitles are presented in a standardized format.
- **Renumbering of Subtitle Sequences**: Adjusts the numbering of subtitles to ensure a sequential order, especially important after the removal of irrelevant text blocks.

## Installation
To get started with this script, you'll need to have Ruby installed on your system. This script has been tested with Ruby versions 2.0 and newer.

1. Download the `renumber_subtitles.rb` script and `blacklist.txt` from this repository.
2. Adjust the contents of `blacklist.txt` to suit your needs.

## Usage
Open a terminal or command prompt and navigate to the directory where you've saved the `renumber_subtitles.rb` script. Use the following command syntax to run the script:

```bash
ruby renumber_subtitles.rb <path_to_subtitle_file_or_directory>
