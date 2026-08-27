## 0.6.0 to 0.7.0

 Before version 0.7.0, Kafka.config was placed at spec.config (unrecognised by Strimzi, apparently)... it now lands at spec.kafka.config where it actually applies. any cluster running 0.6.0 with the default values has had those broker configs ignored since deploy, and upgrading to 0.7.0 will apply them for the first time and may (likely) to trigger a rolling restart
