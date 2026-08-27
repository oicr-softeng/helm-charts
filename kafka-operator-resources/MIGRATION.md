## 0.6.0 to 0.7.0

### Breaking: `Kafka.config` now applies for the first time

Before 0.7.0, `Kafka.config` was placed at `spec.config` in the rendered Kafka resource -- an unrecognized path that Strimzi silently ignored. It now lands at the correct location, `spec.kafka.config`.

Any cluster running 0.6.0 with `Kafka.config` set (including the default replication-factor and ISR values) has had those broker settings dropped since deploy. Upgrading to 0.7.0 will apply them for the first time; expect a rolling restart if the running broker configuration differs from the values in your `Kafka.config`.

### Breaking: chart is now KRaft-only

The `kafkaMode` value has been removed. All resources (Kafka, KafkaNodePool) now render unconditionally rather than being gated on `kafkaMode: kraft`. If you previously set that explicitly, remove it from your values.

Non-KRaft (ZooKeeper) deployments are no longer supported by this chart.
