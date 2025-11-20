// https://www.linkedin.com/posts/llarsson_kubernetes-kubernetes-platformengineering-activity-7397288791784325120-2590

Do you know how hashtag#Kubernetes Quality of Service (QoS) classes (Guaranteed, Burstable, BestEffort) affect Pod scheduling and eviction priority? 
Let's dive into this powerful topic!

Scheduling priority means in what order your Pods will be considered by the Kubernetes scheduler.

Intuitively, we can compare QoS classes to airline tickets. It's a bit of a stretch, but work with me here (you/Pods get scheduled onto flights/Nodes):

Guaranteed: A confirmed first-class ticket. You're the last to be bumped.

Burstable: A standard economy ticket. Your seat allocation is safe, but not as safe as first class.

BestEffort: Flying standby. You're the first to be bumped if the flight is overbooked.

For application developers, the important task of choosing the right one makes the intent clear.

➡️ Run your most important applications (databases, backend APIs) as Guaranteed to give them the highest stability and prevent them from being terminated during node stress.

➡️ Use Burstable for standard applications that can tolerate some performance fluctuation but are still important (e.g., web frontends, caching services).

➡️ Reserve BestEffort for tasks that can be safely interrupted and restarted, like one-off batch jobs or low-priority development experimens.

OK, so how do you get these QoS classes? By specifying resource requests and limits. The rules are as follows:

1️⃣ Guaranteed
If resource requests and limits are set for ALL containers in the Pod, and request = limit in each and every one, respectively, the Pod is in the Guaranteed QoS class.
So if a Pod has containers A and B: requested(A) = limits (A) and requested(B) = limits(B)
Guaranteed is the highest scheduling priority, and the lowest eviction priority (last to be evicted).

2️⃣ Burstable
At least one container in a Pod has resource requests that are less than its limits (or requests set without a limit, so the default is used).
For instance, a Pod has containers A and B: requested(A) < limits(A), B has neither requests nor limit
Burstable has medium scheduling and eviction priority, and will get evicted before any Guaranteed Pods (but after all BestEffort ones).

3️⃣ BestEffort
No resource requests or limits for any container in the Pod.
BestEffort has lowest scheduling priority and highest eviction priority, so they get evicted the instant capacity is needed. 
And don't get scheduled unless all Guaranteed and Burstable have already gotten their share.

As always, Kubernetes is great at automation, but it can only help you as long as you make your intent clear.
