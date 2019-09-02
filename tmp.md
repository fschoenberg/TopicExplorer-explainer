## Create Import-Folder with Text Files
1. Use the file manager, e.g. Windows File Explorer on Windows or Finder on Mac OS, and navigate to the TopicExplorer-docker project, which is a folder named `TopicExplorer-docker`.
2. Create a new folder in the sub directory `TopicExplorer-docker/volumes/input-corpora/text/` with the name of the new corpus, e.g. `TopicExplorer-docker/volumes/input-corpora/text/MY_CORPUS`.  
The corpus name
    - must not contain any white space characters,
    - has to start with a upper case letter and
    - after the first character may come up to 16 characters that may be a combination of upper case letters, numbers and underscores.
    - Make sure that the new corpus name has not been used already for any other corpus in any language in your TopicExplorer instance. If in doubt check the corpora overviews on the creator pages of all languages.
3. Copy all text files into the new sub folder. Make sure that all text file use UTF-8 encoding. Note that word files are not text files.

#### Options
- The folder with corpus may contain nested sub folders. In this case, nested folder structure will be converted into flat files later in the import workflow.

#### Result of this step
A new sub folder within the Topicexplorer docker folder with the name of new corpus. The corpus name need to be used in the next step.

## Prepare to specify and run Import with Jobson
The next step take you to the Jobson user interface that allows you to select the job type, to input the necessary parameters for the job and finally submit and start the job.

1. Select in the field *Job Spec* the Option *Import folder with text files*.
2. Then fill out the form below

    1. Choose a meaningful job name
    2. Specify the corpus name as the input folder, e.g. continuing the example `MY_CORPUS`
    3. Specify the handling of sub folders, e.g. with or without subfolders of the folder MY_CORPUS.
    4. Select the appropriate combination of TopicExplorer Database, NLP-software and language
3. Submit Job, which starts the jobs

#### Result of the next step
After submitting the job, the job is started. Jobson shows then job details and output. Furthermore, the overview page of Jobson shows the current state of all jobs (running, fatal-error, finished) including the one just submitted.

## Specify and run Import with Jobson
The Jobson user interface allows you to select the job type, to input the necessary parameters for the job and finally submit and start the job.

1. Select in the field *Job Spec* the Option *Import folder with text files*.
2. Then fill out the form below

    1. Choose a meaningful job name
    2. Specify the corpus name as the input folder, e.g. continuing the example `MY_CORPUS`
    3. Specify the handling of sub folders, e.g. with or without subfolders of the folder MY_CORPUS.
    4. Select the appropriate combination of TopicExplorer Database, NLP-software and language
3. Submit Job, which starts the jobs

#### Result of this step
After submitting the job, the job is started. Jobson shows then job details and output. Furthermore, the overview page of Jobson shows the current state of all jobs (running, fatal-error, finished) including the one just submitted.


## Monitor Import Job until finished
