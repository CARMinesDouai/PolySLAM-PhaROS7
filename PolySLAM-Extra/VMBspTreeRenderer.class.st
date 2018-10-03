Class {
	#name : #VMBspTreeRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #helper }
VMBspTreeRenderer >> colorByType: aVMLineType [
	aVMLineType isObstacle ifTrue: [ ^Color red ].
	aVMLineType isFrontier ifTrue: [ ^color green ].
	^Color yellow.
]

{ #category : #rendering }
VMBspTreeRenderer >> renderIPSectorsOn: aCanvas [
	"deprecated - used to visualize some experimental code"
	| sectors h |
	
	sectors := model planeIntersectionPoints.
	
	h := 72.
	
	sectors do: [ :aSector |
		self renderFilledPolygonOn: aCanvas collection: aSector color: (Color h: h s: 0.9 v: 0.9).
		h := (h + 53) \\ 360.
	].
]

{ #category : #helper }
VMBspTreeRenderer >> renderLineSegments [
	^false
]

{ #category : #helper }
VMBspTreeRenderer >> renderLineSegmentsOn: aCanvas node: aNode [
	aNode ifNil: [ ^self ].
	
	self renderLineSegmentsOn: aCanvas node: aNode leftChild.
	self renderLineSegmentsOn: aCanvas node: aNode rightChild.
	
	aNode plane ifNotNil: [
		self renderStyledLineSegFrom: aNode plane pointA to: aNode plane pointB on: aCanvas color: (self colorByType: aNode plane type).
	].
	


]

{ #category : #rendering }
VMBspTreeRenderer >> renderOn: aCanvas viewer: aViewer [
	
	self renderSectors ifTrue: [
		self renderSectorsOn: aCanvas.
	].

	self renderLineSegments ifTrue: [
		self renderLineSegmentsOn: aCanvas node: model.
	].

]

{ #category : #helper }
VMBspTreeRenderer >> renderSectors [
	^true
]

{ #category : #rendering }
VMBspTreeRenderer >> renderSectorsOn: aCanvas [
	
	self renderSectorsOn: aCanvas node: model hue: 72
	
"	| h |
	h := 72.
	
	sectors do: [ :aSector |
		self renderFilledPolygonOn: aCanvas collection: aSector color: (Color h: h s: 0.9 v: 0.9).
		h := (h + 53) \\ 360.
	].
"

]

{ #category : #rendering }
VMBspTreeRenderer >> renderSectorsOn: aCanvas node: aNode hue: h [
	
	aNode isLeaf
		ifTrue: [
			aNode sector ifNotNil: [	
				self renderFilledPolygonOn: aCanvas lineSegments: aNode sector color: (Color h: h s: 0.7 v: 0.9).
			].
		]
		ifFalse: [
			aNode leftChild ifNotNil: [
				self renderSectorsOn: aCanvas node: aNode leftChild hue: (h + 53) \\ 360.
			].
			
			aNode rightChild ifNotNil: [
				self renderSectorsOn: aCanvas node: aNode rightChild hue: (h + 113) \\ 360.
			].
		].
	

]
