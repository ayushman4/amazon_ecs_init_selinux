# amazon_ecs_init_selinux
A default Selinux policy for amazon_ecs_init service which is the ecs-agent

This also allows us to understand what access these processes need and what abilities they have.

```
https://github.com/aws/amazon-ecs-init
https://github.com/aws/amazon-ecs-agent
```
ECS processes in host

```
system_u:system_r:amazon_ssm_agent_t:s0 root 3118  1  0 23:47 ?        00:00:00 /usr/bin/amazon-ssm-agent
system_u:system_r:amazon_ssm_agent_t:s0 root 3579 3118  0 23:47 ?      00:00:00 /usr/bin/ssm-agent-worker
system_u:system_r:amazon_ecs_init_t:s0 root 3738   1  0 23:47 ?        00:00:00 /usr/libexec/amazon-ecs-init start
system_u:system_r:amazon_ecs_init_t:s0 root 4246   1  0 23:53 ?        00:00:00 /usr/libexec/amazon-ecs-volume-plugin
```
