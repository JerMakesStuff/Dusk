/// MIT License
/// Copyright (c) 2024 JerMakesStuff
/// See LICENSE

package ecs
import "core:log"

@(deprecated = "queryComponent is depricated, use query instead")
queryComponent :: proc(world: ^World, $T: typeid) -> []Entity {
	tid := typeid_of(T)
	entities := make([dynamic]Entity, context.temp_allocator)
	ents := &world.entityComponentLookup[tid]
	for ent in ents {
		if !isEntityValid(ent) do continue
		append(&entities, ent)
	}
	return entities[:]
}

@(deprecated = "queryComponents is depricated, use query instead")
queryComponents :: proc(world: ^World, comps: ..typeid) -> []Entity {
	entities := make([dynamic]Entity, context.temp_allocator)
	matchCounts: map[Entity]int

	compCounts := len(comps)
	for comp in comps {
		lookup, lookupOk := &world.entityComponentLookup[comp]
		if lookupOk {
			for ent in lookup {
				if !isEntityValid(world, ent) do continue
				_, hasEnt := matchCounts[ent]
				if !hasEnt do matchCounts[ent] = 1
				else do matchCounts[ent] += 1
			}
		} else {
			log.debug("[DUSK][ECS] No entities have component of type", comp)
		}
	}

	for ent, count in matchCounts {
		if count == compCounts do append(&entities, ent)
	}

	return entities[:]
}
