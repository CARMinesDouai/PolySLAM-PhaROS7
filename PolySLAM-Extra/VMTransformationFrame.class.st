Class {
	#name : #VMTransformationFrame,
	#superclass : #Object,
	#instVars : [
		'position',
		'orientation',
		'parent',
		'children',
		'id'
	],
	#category : #'PolySLAM-Extra-Simulator'
}

{ #category : #'as yet unclassified' }
VMTransformationFrame class >> position: aPoint orientation: rad [

	^(self new)
		position: aPoint;
		orientation: rad;
		yourself.
]

{ #category : #'as yet unclassified' }
VMTransformationFrame class >> position: aPoint orientation: rad id: aString [

	^(self new)
		position: aPoint;
		orientation: rad;
		id: aString;
		yourself.
]

{ #category : #'rendering support' }
VMTransformationFrame class >> rendererClass [
"	^ VMTransformationFrameRenderer."
]

{ #category : #adding }
VMTransformationFrame >> addChild: frame [
	children add: frame.
]

{ #category : #converting }
VMTransformationFrame >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #converting }
VMTransformationFrame >> asVMTFMatrix [
	^VMTFMatrix angle: orientation translation: position
]

{ #category : #'as yet unclassified' }
VMTransformationFrame >> asVMTransformationFrame [
	^self.
]

{ #category : #accessing }
VMTransformationFrame >> children [
	^children.
]

{ #category : #'as yet unclassified' }
VMTransformationFrame >> frame [
	| parentFrame |
	
	parent ifNil: [
		parentFrame := VMTransformationFrame new.
	] ifNotNil: [ 
		parentFrame := parent frame copy.
	].
	
	parentFrame position:
		(parentFrame position +
			(self position rotateBy: (parentFrame orientation) about: (0@0))
			"(self position rotateBy: (parentFrame orientation) about: (parentFrame position))"
		).
	
	parentFrame orientation: parentFrame orientation + orientation.
	parentFrame id: (id, ' (copy)').
	
	^parentFrame.
]

{ #category : #accessing }
VMTransformationFrame >> id [
	^id.
]

{ #category : #accessing }
VMTransformationFrame >> id: name [
	id := name.
	

]

{ #category : #initialization }
VMTransformationFrame >> id: frameId parent: parentFrame [

	id := frameId.
	parent := parentFrame.
	
	self register.
]

{ #category : #initialization }
VMTransformationFrame >> initialize [
	position := 0@0.
	orientation := 0.
	parent := nil.
	children := OrderedCollection new.
	id := 'unnamed frame'.
]

{ #category : #'as yet unclassified' }
VMTransformationFrame >> inverse [
	| frame newFrame |
	
	frame := self frame.
	newFrame := VMTransformationFrame new.
	newFrame position: (frame position negated rotateBy: frame orientation negated about: 0@0).
	newFrame orientation: frame orientation negated.
	newFrame id: (id, ' (inv)').
	
	^newFrame.
]

{ #category : #'as yet unclassified' }
VMTransformationFrame >> linkWithParent: parentFrame [
	parent := parentFrame.
	parentFrame addChild: self.
]

{ #category : #'as yet unclassified' }
VMTransformationFrame >> multiplyLeft: parentFrame [
	| frameCopy |
	
	frameCopy := parentFrame copy.
	
	frameCopy position:
		(frameCopy position +
			(self position rotateBy: (frameCopy orientation) about: (0@0))
			"(self position rotateBy: (frameCopy orientation) about: (frameCopy position))"
		).
	
	frameCopy orientation: frameCopy orientation + orientation.
	frameCopy id: (id, ' (copy)').
	
	^frameCopy.
]

{ #category : #accessing }
VMTransformationFrame >> orientation [
	^orientation.
]

{ #category : #accessing }
VMTransformationFrame >> orientation: radians [
	orientation := radians.
]

{ #category : #accessing }
VMTransformationFrame >> parent [
	^parent.
]

{ #category : #accessing }
VMTransformationFrame >> parent: frame [
	parent := frame.
]

{ #category : #accessing }
VMTransformationFrame >> position [
	^position.
]

{ #category : #accessing }
VMTransformationFrame >> position: aPoint [
	position := aPoint.
]

{ #category : #printing }
VMTransformationFrame >> printString [
	^'id=', id asString,
		' [', (position x printShowingDecimalPlaces: 3), '@', (position y printShowingDecimalPlaces: 3),
		', ', (orientation printShowingDecimalPlaces: 3), ']'.
]

{ #category : #accessing }
VMTransformationFrame >> register [
	VMTFServer singleton add: self.
]
