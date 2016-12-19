# Run the Appeal to the Tax Tribunal system locally

This project aims to provide a way for developers to run the entire system locally,
including all the different component services.

## Pre-requisites

* A `mojfile-uploader` symlink to a checkout of `https://github.com/ministryofjustice/mojfile-uploader`
* A `tax-tribunals-datacapture` symlink to a checkout of `https://github.com/ministryofjustice/tax-tribunals-datacapture`
* An S3 bucket plus appropriate IAM users/policies for the uploader/downloader (see `http://github.com/ministryofjustice/s3-bucket-setup`)
* An `.env.datacapture` file for the environment variables required by the datacapture application (see env.datacapture.example)
* An `.env.mojfile-uploader` file for the environment variables required by the mojfile-uploader application (see env.mojfile-uploader.example)

## Usage

`make build`
`make run`
`make init` in a separate terminal window

Now you should be able to interact with the system at `http://localhost:3000`

## Notes

See the `Makefile` for some useful commands.
