# The XR Subsystem

To support XR (which is the support for Virtual, Augmented or Mixed Reality output) we have a few routines that help deal with this.

## Classes related to XR

We have 3 NSXRInput class instances per ncClient class, which itself belongs to a NSXRSpace.

### Head

The head is an NSXRInput of type XR_INPUT_HEAD. Yes, a head is just like any other XR compatible controller. It has a gyro and it potentially has buttons the user can press.

### Hands

We have two hands available, that will identify themselves as XR_INPUT_LEFT or XR_INPUT_RIGHT respectively. These are your primary tools for interacting with the 3D world.