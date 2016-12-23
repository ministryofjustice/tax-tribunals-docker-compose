build:
	docker-compose build

up:
	docker-compose up

down:
	docker-compose down

dev-up:
	docker-compose -f docker-compose-dev.yml up

dev-down:
	docker-compose -f docker-compose-dev.yml down

# Run this in a separate terminal window, after starting the system
# You should only need to do this once, although you will have to run
# subsequent database migrations manually, if any are required (or just
# recreate the database container)
init:
	make init-datacapture
	make init-fees

init-datacapture:
	docker-compose exec datacapture rails db:setup
	docker-compose exec datacapture rails assets:clobber
	docker-compose exec datacapture rails assets:precompile

init-fees:
	docker-compose exec fees rails db:setup
	docker-compose exec fees rails assets:clobber
	docker-compose exec fees rails assets:precompile

# Run this in a separate terminal window, after starting the system
# You should only need to do this once, although you will have to run
# subsequent database migrations manually, if any are required (or just
# recreate the database container)
init-dev:
	docker-compose -f docker-compose-dev.yml exec fees-dev rails db:setup
	docker-compose -f docker-compose-dev.yml exec datacapture-dev rails db:setup

# Help in setting up the environment variables required to access the S3 bucket (see bucket-ls)
env-uploader:
	cat env.mojfile-uploader | sed 's/^/export /' > .env.mojfile-uploader; echo "Now run: source .env.mojfile-uploader"

# Recursively list all the files in the S3 bucket
# You need to set your environment variables first (see env-uploader)
bucket-ls:
	s3cmd --access_key=$${AWS_ACCESS_KEY_ID} --secret_key=$${AWS_SECRET_ACCESS_KEY}   ls -r s3://$${BUCKET_NAME}

test:
	docker exec -it taxtribunalsdockercompose_datacapture_1 rails r 'res = PaymentUrl.new(case_reference: "TC/2016/00064", confirmation_code: "CAPFXY").call!; puts res.inspect'

test-dev:
	docker-compose -f docker-compose-dev.yml run datacapture-dev rails r 'res = PaymentUrl.new(case_reference: "TC/2016/00064", confirmation_code: "CAPFXY").call!; puts res.inspect'

.PHONY: test
