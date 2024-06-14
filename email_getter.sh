#!/bin/bash
mkdir emails/

timestamp=$(date +"%Y-%m-%d_%H-%M-%S")

scp root@157.245.74.234:/root/euphya/emails.csv emails/emails_$timestamp.csv
