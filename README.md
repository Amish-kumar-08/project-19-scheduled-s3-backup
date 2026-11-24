# Project 19: Scheduled S3 Backup Using Linux Cron and AWS CLI

## Project Overview

Implemented an automated Linux system log backup solution using Bash scripting, Cron jobs, AWS CLI, and Amazon S3.

The project automatically collects real Linux system logs from `/var/log`, compresses them into timestamped `.tar.gz` archives, and uploads the backup files to an Amazon S3 bucket at scheduled intervals.

Cron automates the backup process every five minutes without requiring manual execution.

## Objectives

- Automate Linux system log backups using Cron jobs.
- Collect actual system logs from the Ubuntu server.
- Compress log files into timestamped backup archives.
- Automatically upload backup archives to Amazon S3.
- Maintain backup execution logs to track successful uploads and failures.
- Verify that backup files are stored in S3.

## Architecture

```text
          Ubuntu Linux VM
                 |
                 v
           Cron Scheduler
          (Every 5 Minutes)
                 |
                 v
             backup.sh
                 |
                 v
       Collect System Logs
             /var/log
                 |
                 v
        Compress Logs (.tar.gz)
                 |
                 v
              AWS CLI
                 |
                 v
           Amazon S3 Bucket
                 |
                 v
          backups/
       system-logs-*.tar.gz
```

## Technologies Used

- AWS
- Amazon S3
- AWS CLI v2
- Ubuntu Linux
- Bash Scripting
- Linux Cron
- TAR and GZIP
- Linux System Logs

## AWS Configuration

| Configuration | Value |
|---|---|
| AWS Region | ap-south-1 (Mumbai) |
| S3 Bucket | project-19-scheduled-backup-590507089733 |
| S3 Backup Prefix | backups/ |
| Authentication | Existing AWS CLI credentials |
| Public Access | Blocked |

## Project Structure

```text
project-19-scheduled-s3-backup/
│
├── backups/
│
├── scripts/
│   └── backup.sh
│
├── backup.log
├── cron.log
├── .gitignore
└── README.md
```

## Implementation Steps

### 1. Created the Project Directory

Created the project directory and organized the backup scripts and output directories.

```bash
mkdir project-19-scheduled-s3-backup

cd project-19-scheduled-s3-backup

mkdir backups scripts

touch backup.log
```

### 2. Verified AWS CLI Configuration

Verified AWS CLI installation and AWS account authentication.

```bash
aws --version

aws sts get-caller-identity

aws configure list
```

### 3. Created an Amazon S3 Bucket

Created an S3 bucket to store the compressed Linux system log backups.

```bash
aws s3api create-bucket \
  --bucket project-19-scheduled-backup-590507089733 \
  --region ap-south-1 \
  --create-bucket-configuration LocationConstraint=ap-south-1
```

### 4. Configured S3 Public Access Protection

Blocked public access to prevent unauthorized access to backup files.

```bash
aws s3api put-public-access-block \
  --bucket project-19-scheduled-backup-590507089733 \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
```

### 5. Created the Backup Script

Created `scripts/backup.sh` to automate the backup process.

The script performs the following operations:

1. Identifies readable Linux system logs from `/var/log`.
2. Generates a timestamp for each backup.
3. Compresses the selected log files using TAR and GZIP.
4. Uploads the compressed archive to Amazon S3 using AWS CLI.
5. Records successful backup execution in `backup.log`.

### 6. Configured the Cron Job

Configured a Cron job to execute the backup script automatically every five minutes.

```bash
crontab -e
```

Cron configuration:

```bash
*/5 * * * * /bin/bash /home/clouduser/Desktop/project-19-scheduled-s3-backup/scripts/backup.sh >> /home/clouduser/Desktop/project-19-scheduled-s3-backup/cron.log 2>&1
```

Verified the scheduled job:

```bash
crontab -l
```

### 7. Verified Cron Service

Checked that the Cron service was running and enabled.

```bash
sudo systemctl status cron
```

Enabled Cron to start automatically during system boot:

```bash
sudo systemctl enable --now cron
```

### 8. Verified Backup Uploads

Checked the backup execution history:

```bash
cat backup.log
```

Listed generated backup archives:

```bash
ls -lh backups/
```

Verified backup files stored in Amazon S3:

```bash
aws s3 ls s3://project-19-scheduled-backup-590507089733/backups/
```

Inspected the contents of a compressed backup:

```bash
tar -tzf backups/system-logs-YYYYMMDD-HHMMSS.tar.gz
```

## Verification Results

Successfully verified the first automated backup execution.

**Verified S3 Backup:**

```text
system-logs-20261124-085001.tar.gz
```

**Backup Size:** Approximately 2.24 MB.

**Backup Execution Log:**

```text
Tue Nov 24 08:50:02 UTC 2026:
SUCCESS - Uploaded system-logs-20261124-085001.tar.gz to S3
```

**Cron Execution:** Confirmed that Cron invoked the backup script at 08:50 and 08:55 UTC.

**Archive Contents:** Verified actual Linux system logs, including:

- syslog
- auth.log
- kern.log
- cloud-init.log
- cloud-init-output.log
- dmesg

## Security Considerations

- Configured Amazon S3 Block Public Access.
- Used existing AWS CLI credentials instead of hardcoding access keys in the backup script.
- Used readable system log files to avoid requiring interactive sudo authentication.
- Kept backup files in a private S3 bucket.
- Avoided committing backup archives and sensitive log data to GitHub.

## Key Learnings

- Automating recurring Linux tasks using Cron.
- Writing Bash scripts for system administration.
- Collecting and compressing Linux system logs.
- Integrating AWS CLI with Linux automation.
- Uploading files to Amazon S3.
- Verifying scheduled job execution through Linux system logs.
- Maintaining backup execution history.

## Project Deliverable

Automated Linux system log backup workflow that periodically collects real system logs, creates compressed archives, and uploads them to Amazon S3 using Cron and AWS CLI.

**GitHub Repository:** [Paste GitHub Repository URL]

**Technologies:** AWS, Amazon S3, AWS CLI, Ubuntu Linux, Bash, Cron, TAR, GZIP.

