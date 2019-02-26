Extension { #name : #Point }

{ #category : #'*PolySLAM-Pipeline-Algo' }
Point >> asPoint [
	^ self
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
