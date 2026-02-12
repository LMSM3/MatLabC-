What you get:

Stable integration (RK4)

Acceleration computed consistently from the ODE

Clean boundary stop at exactly h=0 (within numerical tolerance)

5) If you want “ode45-level” (adaptive RK45)

Then you add:

a RK45 embedded pair (5th order solution + 4th order estimate)

compute err = norm(y5 - y4)

accept step if err <= tol, otherwise shrink dt

grow dt when error is tiny

If you don’t want to write that by hand (reasonable), use:

Boost.Odeint (C++): has RK4, RKCK54, dense output, controlled steppers

SUNDIALS CVODE: industrial-grade adaptive solvers + events (bigger hammer)

Conceptually, it’s the same state function f(t,y) you saw above. That part never changes.

6) Terminal velocity (bonus: compute it cleanly)

For quadratic drag, terminal speed magnitude is:

𝑣
𝑡
=
2
𝑚
𝑔
𝜌
𝐶
𝑑
𝐴
v
t
	​

=
ρC
d
	​

A
2mg
	​

	​


That’s a nice validation check: your simulation’s |v| should asymptotically approach v_t.

Differential Functions:

Ideal balance between accuracy, weight, application to model is ODE45 , oODE 45 is also essentially a baseline accuracy. 

Applications for curve fiting 

1) Encode it as a state ODE (the only sane way)

Instead of “velocity update” and “acceleration update” as separate spreadsheet rituals, treat them as one vector state:

𝑦
=
[
ℎ


𝑣
]
,
𝑑
𝑑
𝑡
[
ℎ


𝑣
]
=
[
𝑣


𝑔
−
𝜌
𝐶
𝑑
𝐴
2
𝑚
 
𝑣
∣
𝑣
∣
]
y=[
h
v
	​

],
dt
d
	​

[
h
v
	​

]=[
v
g−
2m
ρC
d
	​

A
	​

v∣v∣
	​

]

h = height above ground (boundary at h = 0)

v = vertical velocity (choose sign convention and stick to it like your life depends on it)

Acceleration is not “stored” as a primary thing. It’s just:

𝑎
(
𝑡
)
=
𝑣
˙
(
𝑡
)
=
𝑔
−
𝑘
 
𝑣
∣
𝑣
∣
,
𝑘
=
𝜌
𝐶
𝑑
𝐴
2
𝑚
a(t)=
v
˙
(t)=g−kv∣v∣,k=
2m
ρC
d
	​

A
	​


That’s how ode45 thinks.

2) What ode45 actually is

MATLAB ode45 is an adaptive Runge–Kutta (4/5) solver (Dormand–Prince). Key features:

variable timestep dt chosen automatically

local error estimate (difference between 4th and 5th order solutions)

you set tolerances (RelTol, AbsTol)

event detection (“stop when h = 0”)

So your “C++ equivalent” is: an RK45 stepper + adaptive dt + event/boundary handling.

3) Boundary/event handling (hit the ground cleanly)

You usually do this:

Integrate forward one step.

If you crossed the boundary (h changed sign), you refine the step to find the event time.

Stop (or bounce, clamp, etc.).

Simplest robust refinement: bisection on the step interval.

4) Minimal C++ skeleton: RK4 + event capture (easy + solid)

RK45 is longer. If you want “better than Euler” without writing half a library, RK4 with a small fixed dt is already a huge upgrade. Add event capture so you don’t tunnel through the floor.
