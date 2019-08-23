Extension { #name : #Point }

{ #category : #'*PolySLAM-Pipeline-Algo' }
Point >> asPSVertex [
	^ PSVertex new setX: self x setY: self y; yourself 
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
Point >> asPoint [
	^ self
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
Point >> inrangeOf:aPoint [
	^ self inrangeOf: aPoint radius: 0.002
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
Point >> inrangeOf:aPoint radius:t [
	^ (self dist: aPoint) <= t 
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
Point >> isEndPoint [
	"used only for Polyslam PSvertex"
	^true
]

{ #category : #'*PolySLAM-Pipeline-Algo' }
Point >> vertexType [
	^0
]
