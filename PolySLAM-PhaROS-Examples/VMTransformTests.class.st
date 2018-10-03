Class {
	#name : #VMTransformTests,
	#superclass : #TestCase,
	#category : #'PolySLAM-PhaROS-Examples-Tests'
}

{ #category : #tests }
VMTransformTests >> testAngle [
	| tf epsilon |
	
	epsilon := 0.0000001.
	tf := VMTransform new
		orientation: (PhaROSRPYOrientation roll: 0 pitch: Float halfPi yaw: 0) asQuaternion;
		translation: (PhaROS3DVector x: 3 y: 4 z: 5).
	
	self assert: (tf angle - Float halfPi) abs < epsilon.

]

{ #category : #tests }
VMTransformTests >> testAsVMTFMatrix [
	| tf mat rot epsilon |
	
	epsilon := 0.0000001.
	tf := VMTransform new
		orientation: (PhaROSRPYOrientation roll: 0 pitch: 0 yaw: Float halfPi) asQuaternion;
		translation: PhaROS3DVector zero.
	
	mat := tf asVMTFMatrix.
	rot := mat rotMatrix.
	
	"rotation matrix should be:
	0   -1
	1    0
	"
	
	self assert: ((rot at: 1 at: 1) abs < epsilon).
	self assert: (((rot at: 1 at: 2) + 1) abs < epsilon).
	self assert: (((rot at: 2 at: 1) - 1)abs < epsilon).
	self assert: ((rot at: 1 at: 1) abs < epsilon).

]

{ #category : #tests }
VMTransformTests >> testConversion [
	"note, that we only test values that actually can be converted to the x-y plane.
	for simplicity we don't add test data that has non-zero z-values or a rotation
	axis other than the z-axis."
	| data epsilon |
	
	epsilon := 0.0000001.
	
	data := {
		{Float pi.  0 @ 0}.
		{Float halfPi.  1 @ 2}.
		{Float halfPi negated.  -0.5 @ 1}.
		{Float pi * 1.576.  -2 @ -1}.
		{0.0.  0 @ 0}.
		{0.1234.  1.2345 @ -2.3456}
	}.
	
	data do: [ :obj |
		| tf mat tf2 |
		tf := VMTransform new
			orientation: (PhaROSRPYOrientation roll: 0 pitch: 0 yaw: obj first) asQuaternion;
			translation: (PhaROS3DVector x: obj second x y: obj second y z: 0.0).
		
		mat := tf asVMTFMatrix.
		tf2 := mat asVMTransform.
		
		self assert: (tf angle closeTo: tf2 angle).
		self assert: (tf translation approximated: (PhaROS3DVector x: obj second x y: obj second y z: 0.0) threshold: 0.0001).
	].
	

]

{ #category : #tests }
VMTransformTests >> testConversion2 [
	| data epsilon |
	
	epsilon := 0.0000001.
	
	data := {
		{Float pi.  0 @ 0}.
		{Float halfPi.  1 @ 2}.
		{Float halfPi negated.  -0.5 @ 1}.
		{Float pi * 1.576.  -2 @ -1}.
		{0.0.  0 @ 0}.
		{0.1234.  1.2345 @ -2.3456}
	}.
	
	data do: [ :obj |
		| mat tf mat2 |
		
		mat := VMTFMatrix
			angle: obj first
			translation: obj second.
		
		tf := mat asVMTransform.
		
		mat2 := tf asVMTFMatrix.
		
		self assert: (mat angle closeTo: mat2 angle).
		self assert: (mat translate asPoint dist: mat2 translate asPoint) < epsilon.
	].
	

]

{ #category : #tests }
VMTransformTests >> testInverse [
	| tf inv epsilon id zero |
	
	epsilon := 0.0000001.
	tf := VMTransform new
		orientation: (PhaROSRPYOrientation roll: 0 pitch: Float halfPi yaw: 0) asQuaternion;
		translation: PhaROS3DVector zero.
	
	inv := tf inverse.
	
	id := tf * inv.
	
	zero := id rotMatrix - (DhbSymmetricMatrix identity: 3).
	1 to: 3 do: [ :i |
		1 to: 3 do: [ :k |
			self assert: ((zero at: i at: k) abs < epsilon).
		].
	].
	
	1 to: 3 do: [ :i |
		self assert: ((id transVec at: 1 at: i) abs < epsilon).
	].

]

{ #category : #tests }
VMTransformTests >> testInverse2 [
	| tf inv epsilon id zero |
	
	epsilon := 0.0000001.
	tf := VMTransform new
		orientation: (PhaROSRPYOrientation roll: 0 pitch: Float halfPi yaw: 0) asQuaternion;
		translation: (PhaROS3DVector x: 3 y: 4 z: 5).
	
	inv := tf inverse.
	
	id := tf * inv.
	
	zero := id rotMatrix - (DhbSymmetricMatrix identity: 3).
	1 to: 3 do: [ :i |
		1 to: 3 do: [ :k |
			self assert: ((zero at: i at: k) abs < epsilon).
		].
	].
	
	1 to: 3 do: [ :i |
		self assert: ((id transVec at: 1 at: i) abs < epsilon).
	].

]

{ #category : #tests }
VMTransformTests >> testLength [
	| tf epsilon |
	
	epsilon := 0.0000001.
	tf := VMTransform new
		orientation: (PhaROSRPYOrientation roll: 0 pitch: Float halfPi yaw: 0) asQuaternion;
		translation: (PhaROS3DVector x: 3 y: 4 z: 5).
	
	self assert: (tf length = (3 squared + 4 squared + 5 squared) sqrt).

]

{ #category : #tests }
VMTransformTests >> testRotMatrix [
	| tf rot id epsilon zero |
	
	epsilon := 0.0000001.
	tf := VMTransform new
		orientation: (PhaROSRPYOrientation roll: 0 pitch: Float halfPi yaw: 0) asQuaternion;
		translation: PhaROS3DVector zero.
	
	rot := tf rotMatrix.
	
	id := rot transpose * rot.
	
	zero := id - (DhbSymmetricMatrix identity: 3).
	1 to: 3 do: [ :i |
		1 to: 3 do: [ :k |
			self assert: ((zero at: i at: k) abs < epsilon).
		].
	].

]

{ #category : #tests }
VMTransformTests >> testRotMatrix2 [
	| tf rot id epsilon zero |
	
	epsilon := 0.0000001.
	tf := VMTransform new
		orientation: (PhaROSRPYOrientation roll: Float halfPi pitch: 0 yaw: 0) asQuaternion;
		translation: PhaROS3DVector zero.
	
	rot := tf rotMatrix.
	
	id := rot transpose * rot.
	
	zero := id - (DhbSymmetricMatrix identity: 3).
	1 to: 3 do: [ :i |
		1 to: 3 do: [ :k |
			self assert: ((zero at: i at: k) abs < epsilon).
		].
	].

]

{ #category : #tests }
VMTransformTests >> testRotMatrix3 [
	| tf rot id epsilon zero |
	
	epsilon := 0.0000001.
	tf := VMTransform new
		orientation: (PhaROSRPYOrientation roll: 0 pitch: 0 yaw: Float halfPi) asQuaternion;
		translation: PhaROS3DVector zero.
	
	rot := tf rotMatrix.
	
	id := rot transpose * rot.
	
	zero := id - (DhbSymmetricMatrix identity: 3).
	1 to: 3 do: [ :i |
		1 to: 3 do: [ :k |
			self assert: ((zero at: i at: k) abs < epsilon).
		].
	].

]
