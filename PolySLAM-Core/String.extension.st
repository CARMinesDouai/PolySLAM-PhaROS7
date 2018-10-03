Extension { #name : #String }

{ #category : #'*PolySLAM-Core' }
String >> asBoolean [
	| lowercase |
	lowercase := self asLowercase.
	lowercase = 'true' ifTrue: [ ^true ].
	lowercase = 'false' ifTrue: [ ^false ].
	self error: 'unable to convert string "', self ,'" to boolean'.
	^ false
]

{ #category : #'*PolySLAM-Core' }
String >> replaceCharacter: charA withCharacter: charB [
	| stream |
	stream := self species new writeStream.
	self do: [ :c |
		c = charA
			ifTrue: [ stream nextPut: charB ]
			ifFalse: [ stream nextPut: c ]
	].
	
	^ stream contents
]

{ #category : #'*PolySLAM-Core' }
String >> replaceCharacter: charA withString: stringB [
	| stream |
	stream := self species new writeStream.
	self do: [ :c |
		c = charA
			ifTrue: [ stream nextPutAll: stringB ]
			ifFalse: [ stream nextPut: c ]
	].
	
	^ stream contents
]
