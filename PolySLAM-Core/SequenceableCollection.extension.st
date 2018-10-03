Extension { #name : #SequenceableCollection }

{ #category : #'*PolySLAM-Core' }
SequenceableCollection >> asRenderableElement [
	^(VMCollectionRenderer model: self)
]

{ #category : #'*PolySLAM-Core' }
SequenceableCollection >> asVMLineSegCollection [
	"assumes that the OrderedCollection contains VMLine (or derived) instances."
	^(VMLineSegCollection new)
		addAll: self;
		yourself
]

{ #category : #'*PolySLAM-Core' }
SequenceableCollection >> asVMPointCollection [
	^(VMPointCollection new: self size)
		addAll: self;
		yourself
]

{ #category : #'*PolySLAM-Core' }
SequenceableCollection >> asVMPolygon [
	"assumes that the OrderedCollection contains line segments that form a valid polygon"
	^(VMPolygon new)
		addAll: self;
		yourself.
]

{ #category : #'*PolySLAM-Core' }
SequenceableCollection >> asVMPolygonCollection [
	"assumes that the OrderedCollection contains VMPolygon instances"
	^(VMPolygonCollection new)
		addAll: self;
		yourself.
]

{ #category : #'*PolySLAM-Core' }
SequenceableCollection >> collectNeighbors: aBlock [
	"returns a collection of size 'self size -1'. aBlock is exectured with two arguments: the element at i and the element at i+1.Array
	example:
		{ #a. #b. #c. #d } asOrderedCollection collectNeighbors: [:a :b | {a. b}].
		result: #(#(#a #b) #(#b #c) #(#c #d))"
	| result |
	result := self species new: self size -1.
	1 to: self size -1 do: [ :index |
		result add: (aBlock cull: (self at: index) cull: (self at: index+1)).
	].
	^ result
]

{ #category : #'*PolySLAM-Core' }
SequenceableCollection >> collectNeighbors: aBlock as: aClass [
	"returns a collection of size 'self size -1'. aBlock is exectured with two arguments: the element at i and the element at i+1.Array
	example:
		{ #a. #b. #c. #d } collectNeighbors: [:a :b | {a. b}] as: OrderedCollection.
		result: #(#(#a #b) #(#b #c) #(#c #d))"
	| result |
	result := aClass new: self size -1.
	1 to: self size -1 do: [ :index |
		result add: (aBlock cull: (self at: index) cull: (self at: index+1)).
	].
	^ result
]

{ #category : #'*PolySLAM-Core' }
SequenceableCollection >> select: aBlock as: aClass [
	| each |
	^ aClass new: self size streamContents: [ :stream|
		1 to: self size do: [ :index |
			(aBlock value: (each := self at: index))
				ifTrue: [ stream nextPut: each ]]]
]

{ #category : #'*PolySLAM-Core' }
SequenceableCollection >> with: aSeqCollection collect: aBlock [
	"same as a normal #collect, but with to sequenceable collections of the same size.
	aBlock receives two parameters (the element from this collection and the element
	from aSeqCollection)."
	| result |
	
	self assert: self size = aSeqCollection size.
	result := self species new: self size.
	1 to: self size do: [ :index |
		result at: index put: (aBlock value: (self at: index) value: (aSeqCollection at: index))
	].
	
	^result
	

]
