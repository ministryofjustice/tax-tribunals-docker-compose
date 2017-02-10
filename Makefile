build:
	docker-compose build

build-emulators:
	docker-compose --file docker-compose-with-emulators.yml build

# Run the whole system, with each container running in
# development mode, and with the source code volume-
# mounted into the container, so that changes show up
# immediately.
up:
	docker-compose up

up-emulators:
	docker-compose --file docker-compose-with-emulators.yml up

down:
	docker-compose down

down-emulators:
	docker-compose --file docker-compose-with-emulators.yml down

start:
	docker-compose start

start-emulators:
	docker-compose --file docker-compose-with-emulators.yml start

stop:
	docker-compose stop

stop-emulators:
	docker-compose --file docker-compose-with-emulators.yml stop

tail:
	find logs/ -name '*.log' | xargs tail -F

# Run this in a separate terminal window, after starting the system
# You should only need to do this once, although you will have to run
# subsequent database migrations manually, if any are required (or just
# recreate the database container)
init:
	docker-compose exec datacapture rails db:setup
	docker-compose exec datacapture rails db:migrate

init-emulators:
	docker-compose --file docker-compose-with-emulators.yml exec datacapture rails db:setup
	docker-compose --file docker-compose-with-emulators.yml exec datacapture rails assets:clobber
	docker-compose --file docker-compose-with-emulators.yml exec datacapture rails assets:precompile

# Help in setting up the environment variables required to access the S3 bucket (see bucket-ls)
env-uploader:
	cat .env.mojfile-uploader | sed 's/^/export /' > .tmp; echo "Now run: source .tmp"

# Recursively list all the files in the S3 bucket
# You need to set your environment variables first (see env-uploader)
bucket-ls:
	s3cmd --access_key=$${AWS_ACCESS_KEY_ID} --secret_key=$${AWS_SECRET_ACCESS_KEY}   ls -r s3://$${BUCKET_NAME}

test:
	docker-compose run datacapture rails r 'res = PaymentUrl.new(case_reference: "TC/2016/00064", confirmation_code: "CAPFXY").call!; puts res.inspect'

.PHONY: test
