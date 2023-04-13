
+ Attach ephemeral container to pod_with_issue using alpine image
+ On the fly, install tcpdump and tshark
+ tcpdump does not need NET_ADMIN capabilities so it will capure traffic and output to stdout ; man tspdump
+ We will analyze it using tshark, that will read from the stdout of tcpdump ; man tshark

```bash
kubectl debug {pod_with_issue} --image alpine:3.17.3 -- sh -c 'apk --update --no-cache add tcpdump tshark ; tcpdump -U -i eth0 -w - tcp port 80 | tshark -r - -T ek -J "frame ip tcp http"'
```

+ Filter network trace from stdoutput of the ephemeral container using JQ

```bash
kubectl logs -f {pod_with_issue} -c {debugger-xxxxx} | grep "^{"| jq -c '.layers|[.frame.frame_frame_time, .http.http_http_response_code, .http.http_http_response_line]'
```

+ On an already running pod, we can do a `kubectl replace raw` and extend the json- output of `kubect get pods` with the next snippet, and add securityContext to an ephemeralContainer
+ The ephemeralContainer image is the one created using the dockerfile

```bash
kubect get pod {pod_with_issue} -o json > pod.json
```

+ Edit the pod.json and add the next string, before dnsPolicy key

```json
        "ephemeralContainers": [
            {
                "env": [
                    {
                        "name": "JFILTER",
                        "value": "frame ip tcp dns http"
                    },
                    {
                        "name": "FILTER",
                        "value": "tcp"
                    }
                ],
                "image": "a9d593e2/tshark-ek:009",
                "imagePullPolicy": "IfNotPresent",
                "name": "debugger-tshark",
                "resources": {},
                "securityContext": {
                    "capabilities": {
                        "add": [
                            "NET_ADMIN"
                        ]
                    }
                },
                "terminationMessagePath": "/dev/termination-log",
                "terminationMessagePolicy": "File"
            }
        ],
        "dnsPolicy": "ClusterFirst",
```

+ Another option is to output the kubectl pod -o json in one line with `jq -c`

```bash
kubectl get pod {pod_with_issue} -o json | jq -c > pod.json
```

+ Edit the pod.json and add the next string, before dnsPolicy key
+ The ephemeralContainer image is the one created using the dockerfile

```json
"ephemeralContainers":[{"env":[{"name":"JFILTER","value":"frame ip tcp dns http"},{"name":"FILTER","value":"tcp"}],"image":"a9d593e2/tshark-ek:009","resources":{},"imagePullPolicy":"IfNotPresent","name":"debugger-tshark","securityContext":{"capabilities":{"add":["NET_ADMIN"]}},"terminationMessagePath":"/dev/termination-log","terminationMessagePolicy": "File"}],
```

+ Run `kubectl replace --raw` using the pod name and the modified pod.json file

```bash
kubectl replace --raw /api/v1/namespaces/default/pods/{pod_with_issue}/ephemeralcontainers -f pod.json
```

+ Filter network trace from stdoutput of the ephemeral container using JQ

```bash
kubectl logs -f {pod_with_issue} -c debugger-tshark | grep "^{"| jq -c '.layers|[.frame.frame_frame_time, .http.http_http_response_code, .http.http_http_response_line]'
```