build:
	docker-compose build

# Run the whole system, with each container running in
# development mode, and with the source code volume-
# mounted into the container, so that changes show up
# immediately.
up:
	docker-compose up

down:
	docker-compose down

start:
	docker-compose start

stop:
	docker-compose stop

tail:
	find logs/ -name '*.log' | xargs tail -F

# Run this in a separate terminal window, after starting the system
# You should only need to do this once, although you will have to run
# subsequent database migrations manually, if any are required (or just
# recreate the database container)
init:
	docker-compose exec fees rails db:setup
	docker-compose exec fees rails db:migrate
	docker-compose exec datacapture rails db:setup
	docker-compose exec datacapture rails db:migrate

init-datacapture:
	docker-compose exec datacapture rails db:setup
	docker-compose exec datacapture rails assets:clobber
	docker-compose exec datacapture rails assets:precompile

init-fees:
	docker-compose exec fees rails db:setup
	docker-compose exec fees rails assets:clobber
	docker-compose exec fees rails assets:precompile

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
