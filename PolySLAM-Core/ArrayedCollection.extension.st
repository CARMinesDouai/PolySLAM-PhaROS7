Extension { #name : #ArrayedCollection }

{ #category : #'*PolySLAM-Core' }
ArrayedCollection >> collectNeighbors: aBlock [
	"returns a collection of size 'self size -1'. aBlock is exectured with two arguments: the element at i and the element at i+1.Array
	example:
		{ #a. #b. #c. #d } collectNeighbors: [:a :b | {a. b}].
		result: #(#(#a #b) #(#b #c) #(#c #d))"
	| result |
	result := self species new: self size -1.
	1 to: self size -1 do: [ :index |
		result at: index put: (aBlock cull: (self at: index) cull: (self at: index+1)).
	].
	^ result
]
