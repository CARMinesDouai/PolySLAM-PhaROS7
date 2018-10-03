"
This is a 6DOF transformation (translation and rotation in 3D space). the translation is represented via a vector (cartesean coordinates), the rotation is stored via a quaternion.


Public API and Key Messages

INSTANCE SIDE:

-angle
	returns the angle of the rotation around the single axis of rotation. always in the range of [pi, 0.0]
- asVMTFMatrix
	returns a VMTFMatrix containg the translation and orientation in the x-y plane
- asVMTransform
	return self (no copy created)
- asVMTransformationFrame
	returns a VMTransformationFrame object. This is kept only for compatibility with older code and will likely be removed in the future
- inverse
	returns a new VMTransform that is the inverse of this object, i.e. the concationation of both transforms results in an identity transformation
- length
	returns the length of the translation, i.e. sqrt( x^2 + y^2 + z^2)
- orientation / orientation: <PhaROSQuaternion)
	accessor for the orientation/rotation
- rotMatrix
	returns a 3x3 rotation matrix based on the orientation.
- transVec
	returns a vector (DhbMatrix) that contains the translation
- translation / translation: <PhaROS3DVector>
	accessor for the translation

CLASS SIDE:

- fromOdomMsg: <a ROS nav_msgs/Odometry message>
	constructs a VMTransform instance from the provided message
- zero
	constructs a VMTransform with zero orientation/translation

 
Internal Representation and Key Implementation Points.

Instance Variables
	orientation:		<PhaROSQuaternion>
	translation:		<PhaROS3DVector>



"
Class {
	#name : #VMTransform,
	#superclass : #Object,
	#instVars : [
		'translation',
		'orientation'
	],
	#category : #'PolySLAM-PhaROS-Examples-Helper'
}

{ #category : #constructor }
VMTransform class >> fromOdomMsg: aMsg [
	^self new
		translation: (PhaROS3DVector from: aMsg pose pose position);
		orientation: (PhaROSQuaternion from: aMsg pose pose orientation);
		yourself.
]

{ #category : #constructor }
VMTransform class >> zero [
	^self new
		translation: PhaROS3DVector zero;
		orientation: PhaROSQuaternion zero;
		yourself.
]

{ #category : #operations }
VMTransform >> * aTransform [
	| newTransform transVec |
	
	newTransform := self class new.
	
	transVec := aTransform transVec * self rotMatrix.
	
	newTransform orientation: self orientation * (aTransform orientation).
	newTransform translation: self translation + (PhaROS3DVector fromDhbVector: transVec).
	
	^newTransform.

]

{ #category : #accessing }
VMTransform >> angle [
	"returns the angle of the rotation in radiens [pi, pi) "
	| angle |
	"note: orientation w can return invalid value of slightly above 1.0 or slightly below -1.0"
	angle := (orientation w forceBetween: -1.0 and: 1.0) arcCos * 2.0.
	
	(angle > Float pi) ifTrue: [ angle := Float twoPi - angle. ].
	
	^angle.
	

]

{ #category : #converting }
VMTransform >> asVMTFMatrix [
	^VMTFMatrix identity
		angle: (self yaw);
		translate: {translation x. translation y}.

]

{ #category : #converting }
VMTransform >> asVMTransform [
	^self.
]

{ #category : #converting }
VMTransform >> asVMTransformationFrame [
	^VMTransformationFrame
		position: (translation x @ translation y)
		orientation: (self yaw).
]

{ #category : #operations }
VMTransform >> inverse [
	| rot trans invRot |
	
	rot := self rotMatrix.
	invRot := rot transpose.
	"invRot := rot."
	trans := DhbMatrix rows: { {translation x. translation y. translation z} }.
	
	trans := trans * -1.0 * invRot.
	
	^self class new
		orientation: orientation inverse;
		"translation: (PhaROS3DVector x: (trans at: 1 at: 1) y: (trans at: 1 at: 2) z: (trans at: 1 at: 3));"
		translation: (PhaROS3DVector fromDhbVector: trans);
		yourself.
	
]

{ #category : #accessing }
VMTransform >> length [
	^(translation x squared + (translation y squared) + (translation z squared)) sqrt.
]

{ #category : #accessing }
VMTransform >> orientation [
	^orientation.
]

{ #category : #accessing }
VMTransform >> orientation: anOrientation [
	orientation := anOrientation.
]

{ #category : #accessing }
VMTransform >> rotMatrix [
	| matrix x22 y22 z22 xy2 xz2 yz2 wx2 wy2 wz2 |
	
	matrix := DhbMatrix new: 3.
	
	x22 := orientation x squared * 2.
	y22 := orientation y squared * 2.
	z22 := orientation z squared * 2.
	
	xy2 := orientation x * orientation y * 2.
	xz2 := orientation x * orientation z * 2.
	yz2 := orientation y * orientation z * 2.
	wx2 := orientation w * orientation x * 2.
	wy2 := orientation w * orientation y * 2.
	wz2 := orientation w * orientation z * 2.
	
	matrix at: 1 at: 1 put: 1 - y22 - z22.
	matrix at: 1 at: 2 put: xy2 - wz2.
	matrix at: 1 at: 3 put: xz2 + wy2.
	
	matrix at: 2 at: 1 put: xy2 + wz2.
	matrix at: 2 at: 2 put: 1 - x22 - z22.
	matrix at: 2 at: 3 put: yz2 - wx2.
	
	matrix at: 3 at: 1 put: xz2 - wy2.
	matrix at: 3 at: 2 put: yz2 + wx2.
	matrix at: 3 at: 3 put: 1 - x22 - y22.
	
	^matrix.

]

{ #category : #accessing }
VMTransform >> transVec [
	^DhbMatrix rows: { {translation x. translation y. translation z} }.
]

{ #category : #accessing }
VMTransform >> translation [
	^translation.
]

{ #category : #accessing }
VMTransform >> translation: aTranslation [
	translation := aTranslation.
]

{ #category : #accessing }
VMTransform >> yaw [
	^orientation asRPY yaw.

]
