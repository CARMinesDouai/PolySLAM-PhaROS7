Extension { #name : #Number }

{ #category : #'*PolySLAM-Core' }
Number >> asDhbVector [
	^{ self }
]

{ #category : #'*PolySLAM-Core' }
Number >> asPMVector [
	^{ self }
]

{ #category : #'*PolySLAM-Core' }
Number >> asTimeString [
	"interpretes self as seconds and prints a human-readable string"
	| days hours minutes seconds stringStream |
	seconds := self.
	days := seconds // (60*60*24).
	seconds := seconds - (days * (60*60*24)).
	hours := seconds // (60*60).
	seconds := seconds - (hours * (60*60)).
	minutes := seconds // 60.
	seconds := seconds - (minutes * 60).
	
	stringStream := String new writeStream.
	days > 0 ifTrue: [
		stringStream nextPutAll: days printString;
		nextPutAll: 'd '].
	(days > 0 or: [hours > 0]) ifTrue: [
		stringStream nextPutAll: hours printString;
		nextPutAll: 'h '].
	((days > 0 or: [hours > 0]) or: [minutes > 0]) ifTrue: [
		stringStream nextPutAll: minutes printString;
		nextPutAll: 'm '].
	stringStream nextPutAll: (seconds round: 2) printString;
		nextPutAll: 's'.
		
	^ stringStream contents
		
	
]

{ #category : #'*PolySLAM-Core' }
Number >> forceBetween: lowerEnd and: upperEnd [
	"limits the number to lie in the range [lowerEnd, upperEnd]."
	self < lowerEnd ifTrue: [ ^lowerEnd ].
	self > upperEnd ifTrue: [ ^upperEnd ].
	^self
	
]
