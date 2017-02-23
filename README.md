# Quickstart

To get the master branch of the FFS app in place and runing on
OSX, open `Terminal.app` or `iTerm.app` and paste the following command into
that window:

```bash
bash <(curl -s https://raw.githubusercontent.com/ministryofjustice/tax-tribunals-docker-compose/master/install-locally.sh)
```

This will install everyting you need, and open your default browser on
the running app when it is finished.

If you need to pull in any changes to the master branch after you have
completed this first installation, just run the command again in the
same directory.

***NOTE:*** This version of the system emulates GLiMR and the MoJ file
uploader app.  You will not be able to alter the GLiMR case, nor upload
different files.  It ***does not*** require network connectivity to run
once it has been installed.  It ***does*** require network connectivity
if you want to update anything on it.

# Run the Appeal to the Tax Tribunal system locally

This project aims to provide a way for developers to run the entire system locally,
including all the different component services.

Currently, to run the system fully standalone, please use the commands
postfixed with `-emulators` as described in in ***Usage***, below.

After the system is built and running, this set of commands will give
you a development/test system that does not require external network
connectivity.

## Pre-requisites

* A `mojfile-uploader` symlink to a checkout of `https://github.com/ministryofjustice/mojfile-uploader`
* A `tax-tribunals-datacapture` symlink to a checkout of `https://github.com/ministryofjustice/tax-tribunals-datacapture`
* A `tax-tribunals-fees` symlink to a checkout of `https://github.com/ministryofjustice/tax-tribunals-fees`
* An S3 bucket plus appropriate IAM users/policies for the uploader/downloader (see `http://github.com/ministryofjustice/s3-bucket-setup`).
* An `.env.datacapture` file for the environment variables required by the datacapture application (see env.datacapture.example)
* An `.env.fees` file for the environment variables required by the fees application (see env.fees.example)
* An `.env.mojfile-uploader` file for the environment variables required by the mojfile-uploader application (see env.mojfile-uploader.example)

### To run with MoJfile Uploader and GLiMR emulators

* A `mojfile-uploader-emulator` symlink to a checkout of `https://github.com/ministryofjustice/mojfile-uploader-emulator`
* A `glimr-emulator` symlink to a checkout of `https://github.com/ministryofjustice/glimr-emulator`

## To setup from scratch;

This assumes that S3 bucket setup has already been done.

git clone https://github.com/ministryofjustice/tax-tribunals-docker-compose
git clone https://github.com/ministryofjustice/mojfile-uploader
git clone https://github.com/ministryofjustice/mojfile-uploader-emulator (optional)
git clone https://github.com/ministryofjustice/tax-tribunals-datacapture
git clone https://github.com/ministryofjustice/tax-tribunals-fees
git clone https://github.com/ministryofjustice/glimr-emulator (optional)

cd tax-tribunals-docker-compose

Create suitable env files (see examples in this repo), or get them from another developer

* .env.datacapture
* .env.mojfile-uploader

* .env.datacapture.emulators

## Usage

`make build` or `make build-emulators`

`make up` or `make up-emulators`

`make init` or `make init-emulators` in a separate terminal window

Now you should be able to interact with the system;

* Data Capture - `http://localhost:3000`

## Notes

See the `Makefile` for some useful commands.

## Todo

* Add the fee payment app.
* Add the downloader app.
