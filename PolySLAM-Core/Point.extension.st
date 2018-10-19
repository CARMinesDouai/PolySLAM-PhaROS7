Extension { #name : #Point }

{ #category : #'*PolySLAM-Core' }
Point >> applyTransform: aVMTFMatrix [
	| tf |
	
	tf := aVMTFMatrix asVMTFMatrix.
	
	^self species x: (
		((tf at: 1 at: 1) * x) + 
		((tf at: 1 at: 2) * y) + 
		(tf at: 1 at: 3)
	) y: (
		((tf at: 2 at: 1) * x) + 
		((tf at: 2 at: 2) * y) + 
		(tf at: 2 at: 3)
	).

]

{ #category : #'*PolySLAM-Core' }
Point >> asDhbVector [
	^(PMVector new: 2)
		at: 1 put: x;
		at: 2 put: y;
		yourself.
]

{ #category : #'*PolySLAM-Core' }
Point >> asRenderableElement [
	^VMPointRenderer model: self
]

{ #category : #'*PolySLAM-Core' }
Point >> asVMPoint [
	^VMPoint x: x y: y.
]

{ #category : #'*PolySLAM-Core' }
Point >> asVMPointTyped: type [
	^ VMPoint x: x y: y type: type
]

{ #category : #'*PolySLAM-Core' }
Point >> asVMVertex [
	^ VMGraphVertex point: self
]

{ #category : #'*PolySLAM-Core' }
Point >> bounds [
	| p |
	p := 0.0001 @ 0.0001.
	^Rectangle point: self - p point: self + p.
]

{ #category : #'*PolySLAM-Core' }
Point >> deltaAngle: aPoint [
	| angleA angleB angleD |
	
	angleA := self angle.
	angleB := aPoint angle.
	angleD := angleB - angleA. "range: [-twoPi, twoPi]"
	
	(angleD > Float pi) ifTrue: [ ^ angleD - Float twoPi ].
	(angleD < Float pi negated) ifTrue: [ ^ angleD + Float twoPi ].
	
	^angleD

]

{ #category : #'*PolySLAM-Core' }
Point >> flipY [
	^x @ (y negated)
]

{ #category : #'*PolySLAM-Core' }
Point >> isEqual: aPoint [
	"equality, ignoring the point type that VMPoints have"
	^ (self x = aPoint x) and: [self y = aPoint y]
]

{ #category : #'*PolySLAM-Core' }
Point >> transform: aVMTFMatrix [
	| tf |
	
	tf := aVMTFMatrix asVMTFMatrix.
	
	^self species x: (
		((tf at: 1 at: 1) * x) + 
		((tf at: 1 at: 2) * y) + 
		(tf at: 1 at: 3)
	) y: (
		((tf at: 2 at: 1) * x) + 
		((tf at: 2 at: 2) * y) + 
		(tf at: 2 at: 3)
	).

]

{ #category : #'*PolySLAM-Core' }
Point >> vectorTo: aPoint [
	^ VMLineSegment from: self to: aPoint
]

{ #category : #'*PolySLAM-Core' }
Point >> vectorTo: aPoint type: aType [
	^ VMLineSegment from: self to: aPoint type: aType
]
