Class {
	#name : #PolySLAMOfflineStream,
	#superclass : #Object,
	#instVars : [
		'slam',
		'running',
		'keyframe'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PolySLAMOfflineStream >> keyframe [
	^ keyframe
]

{ #category : #accessing }
PolySLAMOfflineStream >> keyframe: anObject [
	keyframe := anObject
]

{ #category : #accessing }
PolySLAMOfflineStream >> runOn: aTopic [
	slam := PolySLAMROS new.
	keyframe := OrderedCollection new.
	slam runOn: aTopic.
	"mappingModule start."
	running := true.
	[ self waitForKeyframe ] forkAt: 41
]

{ #category : #accessing }
PolySLAMOfflineStream >> running [
	^ running
]

{ #category : #accessing }
PolySLAMOfflineStream >> running: anObject [
	running := anObject
]

{ #category : #fileout }
PolySLAMOfflineStream >> saveTo: aFile [
	FLSerializer serialize: keyframe toFileNamed: aFile 
]

{ #category : #accessing }
PolySLAMOfflineStream >> slam [
	^ slam
]

{ #category : #accessing }
PolySLAMOfflineStream >> slam: anObject [
	slam := anObject
]

{ #category : #initialization }
PolySLAMOfflineStream >> stop [
	|tmp|
	running := false.
	"flush the io stream"
	tmp := true.
	slam stop.
	[tmp] whileTrue: [
		slam iostream atEnd ifFalse: [ 
			slam iostream next = true ifTrue: [ tmp := false ]
		] ifTrue:[100 milliSecond wait]].
	slam close.
	slam := nil
]

{ #category : #sync }
PolySLAMOfflineStream >> waitForKeyframe [
|scan|
[ running ] whileTrue: [ 
	slam iostream atEnd
	ifTrue: [ 100 milliSeconds wait ]
	ifFalse:[
		scan := slam iostream next.
		"mappingModule addKeyframe: scan."
		keyframe add: scan.
		Transcript show:'added keyframe: ', (scan id asString);cr
	]	
]
]
