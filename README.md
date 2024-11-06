#  CreateML Image Distribution    

# Purpose

This MacOS App prepares image data for the Apple CreateML utility which can be invoked from Xcode, by creating directories based on a spreadsheet of categories, attributes and images.

E.g: A spreadsheet of the format: 
Photoname,    Rank ,   Suit
1club.jpg,    Ace,    clubs
4spades.jpg,    4 ,   spades
...

allows the photos to be copied to a directory called *suit* or a directory called *rank* or both.
Once these directories have been created by this App, then CreateML can be used to train a model based on the categories you have selected and the images within these catagories. This overcomes createML's' limitation that it cannot combine a spreadsheet of properties with collections of photos or other immages.  This combination is often found on Kaggle and other ml platforms.

# Prerequisites
MacOS 15 or later (since @Observation is used)

# Execution Instructions
1. Select the spreadsheet catalogue of images
1. Identify which of the columns in the spreadsheet refers to the image, and which do you intend to use as categories
1. Select the folder that holds the images
1. Select the directory where you would like the images copied to.
1. Execute - New subfolders are created, one for each category. And within the subfolders new subfolders are created one for each property.

# Test Instructions

## Download the Spreadsheet
1. Download the spreadsheet file from the TestMedia asset.

## Place the Spreadsheet
1. You can place the spreadsheet in any directory of your choice.
1. Note the directory path where you placed the spreadsheet.
1. Edit the scheme *CreateMLImageDistributorTests* so that the Run Environment variable *SPREADSHEET_PATH* points to this directory path.

## Running the Tests
1. Open the Xcode project.
2. Select the test target.
3. Run the tests using `Command + U`.

## Specifying the Spreadsheet Location
1. When prompted, select the directory where you placed the spreadsheet.
2. Ensure the file name matches `TestSpreadsheet.csv`.



