Class {
	#name : #PSMapping,
	#superclass : #Object,
	#instVars : [
		'map',
		'update_per_n_kf',
		'interval'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PSMapping >> addPolygon: p [
	<master>
	"self iostream ifNil: [ ^self ].
	self iostream isOpen ifFalse:[^self].
	self iostream  nextPut: p"
	self processData: p
]

{ #category : #initialization }
PSMapping >> initialize [
	super initialize.
	map := VMBSPLeaf new.
	update_per_n_kf := 5. 
	interval := 0.
]

{ #category : #accessing }
PSMapping >> map [
	^ map
]

{ #category : #process }
PSMapping >> processData: d [
	|p|
	p := d.
	[
		VMBSPLeaf new insert: d.
		map := map insert: d.
		interval := interval + 1.
		interval > update_per_n_kf ifTrue:[
			"self iostream nextPut: "self rasterize.
			interval := 0
		]
	] on: Error do: [ Transcript show: 'Slave VM: Error on adding polygon'; cr ]

]

{ #category : #process }
PSMapping >> rasterize [
	|sectors canvas|
	"draw everything on a canvas
	then rasterize it to a bitmap"
	sectors := self maps asCollectionOfSectors.
	sectors inspect.
	"canvas := TRCanvas new."
	
]

{ #category : #process }
PSMapping >> start [
	<master>
	"do nothing cause it already running"
	Transcript show: 'Running mappinng module'; cr.
]

{ #category : #process }
PSMapping >> stop [
	<master>
	"self close.
	self iostream: nil"
]
