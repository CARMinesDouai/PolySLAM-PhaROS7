"
The ObjectReference class is a singelton that stores refernces to object.

This class is meant to store parent-child relationships in an external object (i.e. not within the objects itself).
It should only be used though the class-side  #at:  and  #at:put  messages.


Public API and Key Messages

- at: <objectA>
	returns a Set of objects that are referencing 'objectA' or nil if objectA is unkown
- at: <objectA> put: <objectB>
	adds an reference from objectB to objectA


Internal Representation and Key Implementation Points.
	The class is derived from a Dictionary. The dictionary keys are the objects that are referenced.
	The paired values to the keys are Sets (or nil if empty), which store the referencing objects.


"
Class {
	#name : #VMObjectReferences,
	#superclass : #Dictionary,
	#classVars : [
		'UniqueInstance'
	],
	#category : #'PolySLAM-Core-temp'
}

{ #category : #accessing }
VMObjectReferences class >> at: objectA [

	^(self singelton) at: objectA
]

{ #category : #accessing }
VMObjectReferences class >> at: objectA put: objectB [
	^(self singelton) at: objectA put: objectB 
]

{ #category : #'as yet unclassified' }
VMObjectReferences class >> resetSingelton [
	UniqueInstance := nil
]

{ #category : #'as yet unclassified' }
VMObjectReferences class >> singelton [
	UniqueInstance ifNil: [UniqueInstance := self new.].

	^UniqueInstance
]

{ #category : #accessing }
VMObjectReferences >> at: objectA put: objectB [
	"add objectB to the set of references to objectA"
	self at: objectA ifAbsent: [ super at: objectA put: Set new. ].
	(self at: objectA) add: objectB.
]
