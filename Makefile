.PHONY: hail-ci-build-image

BUILD_IMAGE_SHORT_NAME = cloud-tools-pr-builder

latest-hail-ci-build-image:
	cd pr-builder && docker build . -t ${BUILD_IMAGE_SHORT_NAME}

hail-ci-build-image: HASH = $(shell docker images -q --no-trunc ${BUILD_IMAGE_SHORT_NAME} | head -n 1 | sed -e 's,[^:]*:,,')
hail-ci-build-image: latest-hail-ci-build-image
	docker tag ${BUILD_IMAGE_SHORT_NAME} ${BUILD_IMAGE_SHORT_NAME}:${HASH}

push-hail-ci-build-image: HASH = $(shell docker images -q --no-trunc ${BUILD_IMAGE_SHORT_NAME} | head -n 1 | sed -e 's,[^:]*:,,')
push-hail-ci-build-image: hail-ci-build-image
	docker tag ${BUILD_IMAGE_SHORT_NAME}:${HASH} gcr.io/broad-ctsa/${BUILD_IMAGE_SHORT_NAME}:${HASH}
	docker push gcr.io/broad-ctsa/${BUILD_IMAGE_SHORT_NAME}:${HASH}
	echo gcr.io/broad-ctsa/${BUILD_IMAGE_SHORT_NAME}:${HASH} > hail-ci-build-image

deploy:
	rm -f dist/*
	python2 setup.py bdist_wheel
	python3 setup.py sdist bdist_wheel
	twine upload dist/*
