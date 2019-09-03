# Create Corpus from Text Files
## Create Import-Folder with Text Files
1. Use the file manager, e.g. Windows File Explorer on Windows or Finder on Mac OS, and navigate to the TopicExplorer-docker project, which is a folder named `TopicExplorer-docker`.
2. Navigate to the subfolder `TopicExplorer-docker` ▶ `volumes` ▶ `input-corpora` ▶ `text`.
3. Within the subfolder `text`, create a new folder with the name of the new corpus, e.g.  `MY_CORPUS`.  
The corpus name
    - has to start with a upper case letter and
    - must not contain any white space characters,
    - after the first character may come up to 16 characters that may be a combination of upper case letters, numbers and underscores.
    - Make sure that the new corpus name has not been used already for any other corpus in any language in your TopicExplorer instance. If in doubt check the corpora overviews on the creator pages of all languages.
4. Copy all text files into the new sub folder, e.g.  `MY_CORPUS`. Make sure that all text files use UTF-8 encoding. Note that word files are not text files.

#### Options
- The folder with the new corpus may contain nested subfolders. In this case, nested folder structure will be converted into flat files later in the import workflow.

#### Result of this step
A new subfolder with the name of new corpus that contains all document as text file, e.g. `TopicExplorer-docker` ▶ `volumes` ▶ `input-corpora` ▶ `text` ▶ `MY_CORPUS` . The corpus name will to be used in the next steps.

## Prepare to specify and run Import with Jobson
The next step will take you to the Jobson user interface that allows you to select the job type, to input the necessary parameters for the job and finally submit and start the job.  
In detail the steps will be:
1. Select in the field *Job Spec* the Option *Import folder with text files*.
![alt Select in the field *Job Spec* the Option *Import folder with text files*.](Create-Corpus-from-Text-Files-3-1.png " In Job Spec select  Option *Import folder with text files*")
2. Then fill out the form below

    1. Choose a meaningful job name.  
    ![alt Choose a meaningful job name.](Create-Corpus-from-Text-Files-3-2.png "Choose a meaningful job name")
    2. Specify the corpus name as the input folder, e.g. continuing the example `MY_CORPUS`.  
    ![alt  Specify the corpus name as the input folder.](Create-Corpus-from-Text-Files-3-3.png " Specify the corpus name as the input folder")
    3. Specify the handling of subfolders, e.g. with or without subfolders of the folder MY_CORPUS.  
    ![alt  Specify the corpus name as the input folder.](Create-Corpus-from-Text-Files-3-4.png " Specify the corpus name as the input folder")
    4. Select the appropriate combination of TopicExplorer Database, NLP-software and language.  
    ![alt  Specify the corpus name as the input folder.](Create-Corpus-from-Text-Files-3-5.png " Specify the corpus name as the input folder")
3. Click the Submit button, which submits and also starts the job.

#### Result of the next step
After submitting the job, the job will be started. Jobson will show then job details and output. Furthermore, the overview page of Jobson will show the current state of all jobs (running, fatal-error, finished) including the one just submitted.

## Specify and run Import with Jobson
The Jobson user interface allows you to select the job type, to input the necessary parameters for the job and finally submit and start the job.

1. Select in the field *Job Spec* the Option *Import folder with text files*.  
![alt Select in the field *Job Spec* the Option *Import folder with text files*.](Create-Corpus-from-Text-Files-3-1.png " In Job Spec select  Option *Import folder with text files*")
2. Then fill out the form below

    1. Choose a meaningful job name.  
    ![alt Choose a meaningful job name.](Create-Corpus-from-Text-Files-3-2.png "Choose a meaningful job name")
    2. Specify the corpus name as the input folder, e.g. continuing the example `MY_CORPUS`.  
    ![alt  Specify the corpus name as the input folder.](Create-Corpus-from-Text-Files-3-3.png " Specify the corpus name as the input folder")
    3. Specify the handling of sub folders, e.g. with or without subfolders of the folder MY_CORPUS.  
    ![alt  Specify the corpus name as the input folder.](Create-Corpus-from-Text-Files-3-4.png " Specify the corpus name as the input folder")
    4. Select the appropriate combination of TopicExplorer Database, NLP-software and language.  
    ![alt  Specify the corpus name as the input folder.](Create-Corpus-from-Text-Files-3-5.png " Specify the corpus name as the input folder")
3. Click the Submit button, which submits and also starts the job.

#### Result of this step
After submitting the job, the job is started. Jobson shows then job details and output, e.g.  
![alt  Import Job is finished.](Create-Corpus-from-Text-Files-4-1.png " Import Job is finished.")

Furthermore, the overview page of Jobson shows the current state of all jobs (running, fatal-error, finished) including the one just submitted.


## Monitor Import Job until finished

1. You can monitor the submitted Job at the overview page of Jobson. Alternatively, you can see the job details and output at the job specific page that shows details and output of the submitted job.
![alt  Import Job is finished.](Create-Corpus-from-Text-Files-4-1.png " Import Job is finished.")
2. After the import job is successfully finished, the new corpus is complete and available in the Creator of the respective language. The example screen shot shows that `MY_CORPUS` is available in the creator for English using the TreeTagger NLP-software. You might need to click *Update overview* to see the corpus.
![alt  Corpus becomes available in the Creator.](Create-Corpus-from-Text-Files-4-2.png " Corpus becomes available in the Creator.")

#### Result of this step
New corpus, e.g. `MY_CORPUS`, is complete and available at the creator page of the respective language.

# Create Corpus from PDF Files
## Overview
This workflow shows you
1. How to convert a folder with PDF files into a folder or Zip-archive with text files.
2. How to continue with the Workflow "Create Corpus from Text Files" to import the text files as a corpus into TopicExplorer.

## Create Folder with PDF Files
1. Use the file manager, e.g. Windows File Explorer on Windows or Finder on Mac OS, and navigate to the TopicExplorer-docker project, which is a folder named `TopicExplorer-docker`.
2. Navigate to the subfolder `TopicExplorer-docker` ▶ `volumes` ▶ `input-corpora` ▶ `text`.
3. Within the subfolder `PDF`, create a new folder with the name of the new corpus, e.g.  `MY_CORPUS`.  
The corpus name
    - has to start with a upper case letter and
    - must not contain any white space characters,
    - after the first character may come up to 16 characters that may be a combination of upper case letters, numbers and underscores.
    - Make sure that the new corpus name has not been used already for any other corpus in any language in your TopicExplorer instance. If in doubt check the corpora overviews on the creator pages of all languages.
4. Copy all PDF files into the new sub folder, e.g.  `MY_CORPUS`. Note that only the selectable text in the PDF files will be converted. In case the PDF files contain images with text that may come from scanning printed documents, you have to use OCR software like Tesseract (https://github.com/tesseract-ocr/tesseract) or Abbyy FineReader (https://www.abbyy.com) first.

#### Options
- The folder with the new corpus may contain nested subfolders. In this case, nested folder structure will be converted into flat files later in the import workflow.

#### Result of this step
A new subfolder with the name of new corpus that contains all document as PDF file, e.g. `TopicExplorer-docker` ▶ `volumes` ▶ `input-corpora` ▶ `pdf` ▶ `MY_CORPUS` . The corpus name will to be used in the next steps.

## Prepare to specify and run Conversion of PDF files with Jobson
The next step will take you to the Jobson user interface that allows you to select the job type, to input the necessary parameters for the job and finally submit and start the job.  
In detail the steps will be:
1. Select in the field *Job Spec* the Option *Convert folder with pdf files to text files*.
![alt Select in the field *Job Spec* the Option *Import folder with text files*.](Create-Corpus-from-Text-Files-3-1.png " In Job Spec select  Option *Import folder with text files*")
2. Then fill out the form below

    1. Choose a meaningful job name.  
    ![alt Choose a meaningful job name.](Create-Corpus-from-Text-Files-3-2.png "Choose a meaningful job name")
    2. Specify the corpus name as the input folder, e.g. continuing the example `MY_CORPUS`.  
    ![alt  Specify the corpus name as the input folder.](Create-Corpus-from-Text-Files-3-3.png " Specify the corpus name as the input folder")
    3. Specify the handling of subfolders, e.g. with or without subfolders of the folder MY_CORPUS.  
    ![alt  Specify the corpus name as the input folder.](Create-Corpus-from-Text-Files-3-4.png " Specify the corpus name as the input folder")
    4. Select the destination of the output folder. The following options are available:
      - Output folder as input folder for corpus import. The output folder name must be a valid corpus identifier. The output folder with the text files is saved as subfolder of  `TopicExplorer-docker` ▶ `volumes` ▶ `input-corpora` ▶ `text`. After the pdf-conversion-job is finished, you can directly continue with the job to import the folder with text files as new corpus.
      - Output folder in Download Zip. The text files are saved in a temporary folder that you can download as Zip file archive. This allows you to edit the text files manually to remove noise from the converted text files. Later you can copy the folder with the edited text files into  `TopicExplorer-docker` ▶ `volumes` ▶ `input-corpora` ▶ `text` and import the folder with text files.
3. Click the Submit button, which submits and also starts the job.

#### Result of the next step
After submitting the job, the job will be started. Jobson will show then job details and output. Furthermore, the overview page of Jobson will show the current state of all jobs (running, fatal-error, finished) including the one just submitted.

## Specify and run Conversion of PDF files with Jobson
The Jobson user interface allows you to select the job type, to input the necessary parameters for the job and finally submit and start the job.  
In detail the steps will be:
1. Select in the field *Job Spec* the Option *Convert folder with pdf files to text files*.
![alt Select in the field *Job Spec* the Option *Import folder with text files*.](Create-Corpus-from-Text-Files-3-1.png " In Job Spec select  Option *Import folder with text files*")
2. Then fill out the form below

    1. Choose a meaningful job name.  
    ![alt Choose a meaningful job name.](Create-Corpus-from-Text-Files-3-2.png "Choose a meaningful job name")
    2. Specify the corpus name as the input folder, e.g. continuing the example `MY_CORPUS`.  
    ![alt  Specify the corpus name as the input folder.](Create-Corpus-from-Text-Files-3-3.png " Specify the corpus name as the input folder")
    3. Specify the handling of subfolders, e.g. with or without subfolders of the folder MY_CORPUS.  
    ![alt  Specify the corpus name as the input folder.](Create-Corpus-from-Text-Files-3-4.png " Specify the corpus name as the input folder")
    4. Select the destination of the output folder. The following options are available:
      - Output folder as input folder for corpus import. The output folder name must be a valid corpus identifier. The output folder with the text files is saved as subfolder of  `TopicExplorer-docker` ▶ `volumes` ▶ `input-corpora` ▶ `text`. After the pdf-conversion-job is finished, you can directly continue with the job to import the folder with text files as new corpus.
      - Output folder in Download Zip. The text files are saved in a temporary folder that you can download as Zip file archive. This allows you to edit the text files manually to remove noise from the converted text files. Later you can copy the folder with the edited text files into  `TopicExplorer-docker` ▶ `volumes` ▶ `input-corpora` ▶ `text` and import the folder with text files.
3. Click the Submit button, which submits and also starts the job.

#### Result of the next step
After submitting the job, the job  is started. Jobson shows then job details and output. Furthermore, the overview page of Jobson shows the current state of all jobs (running, fatal-error, finished) including the one just submitted.


## Monitor Conversion Job until finished

1. You can monitor the submitted Job at the overview page of Jobson. Alternatively, you can see the job details and output at the job specific page that shows details and output of the submitted job.
![alt  Import Job is finished.](Create-Corpus-from-Text-Files-4-1.png " Import Job is finished.")
2. After the conversion job is successfully finished, the new subfolder with text files available in `TopicExplorer-docker` ▶ `volumes` ▶ `input-corpora` ▶ `text` and ready for being imported or the Zip file archive with the text files can be downloaded, manually edited and then imported.

#### Result of this step
A folder with text files or a Zip file archive that contains the text files.
