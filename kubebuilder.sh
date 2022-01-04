mkdir cronjob
cd cronjob
go mod init github.com/tutorial/cronjob

# we'll use a domain of tutorial.kubebuilder.io,
# # so all API groups will be <group>.tutorial.kubebuilder.io.
kubebuilder init --domain tutorial.kubebuilder.io
kubebuilder create api --group batch --version v1 --kind CronJob

kubebuilder create webhook --group batch --version v1 --kind CronJob --defaulting --programmatic-validation

go mod vendor
make
make install
./bin/manager
#kustomize build config/crd

