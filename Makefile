# https://github.com/radanalyticsio/openshift-spark
LOCAL_IMAGE=spark
#SPARK_IMAGE=mattf/openshift-spark

# If you're pushing to an integrated registry
# in Openshift, SPARK_IMAGE will look something like this

SPARK_IMAGE=192.168.1.5:5001/test/${LOCAL_IMAGE}

all: build push

build:
	docker build -t $(LOCAL_IMAGE) .

clean:
	docker rmi $(LOCAL_IMAGE)

push: build
	docker tag -f $(LOCAL_IMAGE) $(SPARK_IMAGE)
	docker push $(SPARK_IMAGE)

create: push template.yaml
	oc process -f template.yaml -v SPARK_IMAGE=$(SPARK_IMAGE) > template.active
	oc create -f template.active

destroy: template.active
	oc delete -f template.active
	rm template.active
