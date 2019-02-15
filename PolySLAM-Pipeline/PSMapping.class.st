Class {
	#name : #PSMapping,
	#superclass : #Object,
	#instVars : [
		'map',
		'update_per_n_kf',
		'interval',
		'onMapUpdate',
		'queue',
		'running'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PSMapping >> addKeyframe: s [
	"<master>"
	"self iostream ifNil: [ ^self ].
	self iostream isOpen ifFalse:[^self].
	self iostream  nextPut: p"
	"self processData: s"
	queue nextPut: s.
	"interval := interval + 1."
	"interval = 20 ifTrue:[
		TimeProfiler spyOn: [ self bench ]	
	]"
]

{ #category : #benchmarking }
PSMapping >> bench [
	[queue atEnd] whileFalse:  [|d| 
		d := queue next.
		[
			map := map insert: d.
		] 	on: Error do: [ Transcript show: 'Slave VM: Error on adding polygon'; cr.].
	]
]

{ #category : #benchmarking }
PSMapping >> benchBSP [
	map := VMBSPLeaf new.
	TimeProfiler spyOn: [ self bench ]
]

{ #category : #benchmarking }
PSMapping >> benchGrid [
	map := ((VMGridStorage gridSize: 2.0) cellClass: VMGridCellBSP; yourself).
	TimeProfiler spyOn: [ self bench ]
]

{ #category : #initialization }
PSMapping >> initialize [
	super initialize.
	map := ((VMGridStorage gridSize: 2.0) cellClass: VMGridCellBSP; yourself).
	update_per_n_kf := 3. 
	interval := 0.
	onMapUpdate := nil.
	queue := SharedQueue new.
	running := false
]

{ #category : #accessing }
PSMapping >> map [
	^ map
]

{ #category : #accessing }
PSMapping >> onMapUpdate [
	^ onMapUpdate
]

{ #category : #accessing }
PSMapping >> onMapUpdate: anObject [
	onMapUpdate := anObject
]

{ #category : #process }
PSMapping >> process [
	[ running ] whileTrue: [ 
		queue atEnd ifFalse: [ self processData: queue next ] ifTrue:[100 milliSeconds  wait]
	]
]

{ #category : #process }
PSMapping >> processData: scan [
	|p|
	p := scan polygon.
	[
		"VMBSPLeaf new insert: d."
		map := map insert: p.
	] on: Error do: [ Transcript show: 'Slave VM: Error on adding polygon'; cr. ^self ].
	"self iostream nextPut: map asCollectionOfSectors."
	Transcript show: 'polygon added to map: ', scan id asString ; cr.
	interval = 0 ifTrue:["self iostream nextPut: map asCollectionOfSectors"
		onMapUpdate ifNotNil: [ onMapUpdate value: map asVMPolygonCollection ]	
	].
	interval := interval + 1.
	interval >= update_per_n_kf ifTrue:[ interval := 0 ].

]

{ #category : #process }
PSMapping >> rasterize [
	|sectors canvas|
	"draw everything on a canvas
	then rasterize it to a bitmap"
	"sectors := self maps asCollectionOfSectors.
	sectors inspect."
	self map inspect.
	"canvas := TRCanvas new."
	
]

{ #category : #process }
PSMapping >> start [
	"<master>"
	Transcript show: 'Running mappinng module'; cr.
	running := true.
	[ self process ] forkAt: Processor userBackgroundPriority 
]

{ #category : #process }
PSMapping >> stop [
	<master>
	running := false
	"self close.
	self iostream: nil"
]
