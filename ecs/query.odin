package ecs

QueryResult :: struct($T1:typeid) {
    entity:Entity,
    value1:^T1
}

QueryResult2 :: struct($T1:typeid, $T2:typeid) {
    using _ : QueryResult(T1),
    value2:^T2
}

QueryResult3 :: struct($T1:typeid, $T2:typeid, $T3:typeid) {
    using _ : QueryResult2(T1, T2),
    value3:^T3
}

QueryResult4 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid) {
    using _ : QueryResult3(T1, T2, T3),
    value4:^T4
}

QueryResult5 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid) {
    using _ : QueryResult4(T1, T2, T3, T4),
    value5:^T5
}

QueryResult6 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid) {
    using _ : QueryResult5(T1, T2, T3, T4, T5),
    value6:^T6
}

QueryResult7 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid) {
    using _ : QueryResult6(T1, T2, T3, T4, T5, T6),
    value7:^T7
}

QueryResult8 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid) {
    using _ : QueryResult7(T1, T2, T3, T4, T5, T6, T7),
    value8:^T8
}

QueryResult9 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid, $T9:typeid) {
    using _ : QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8),
    value9:^T9
}

QueryResult10 :: struct($T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid, $T9:typeid, $T10:typeid) {
    using _ : QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9),
    value10:^T10
}

query_1 :: proc(world:^World, $T1:typeid) -> []QueryResult(T1) {
    entities := make([dynamic]QueryResult(T1), context.temp_allocator)
    lookup, lookupOk := &world.entityComponentLookup[typeid_of(T1)]
    if lookupOk {
        for entity in lookup {
            if !isEntityValid(world, entity) do continue
            result:QueryResult(T1)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, lookup, T1)
            append(&entities, result)
        }
    }
    return entities[:]
}

query_2 :: proc(world:^World, $T1:typeid, $T2:typeid) -> []QueryResult2(T1, T2) {
    entities := make([dynamic]QueryResult2(T1, T2), context.temp_allocator)
    matchCounts:map[Entity]int
    lookups:[2]^map[Entity]int

    lookups[0] = _query_lookup_count_for_type(world, &matchCounts, T1)
    if lookups[0] == nil do return entities[:]
    lookups[1] = _query_lookup_count_for_type(world, &matchCounts, T2)
    if lookups[1] == nil do return entities[:]
    
    for entity, count in matchCounts {
        if count == 2 {
            result:QueryResult2(T1, T2)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, lookups[0], T1)
            result.value2 = _query_get_component_from_lookup(world, entity, lookups[1], T2)
            append(&entities, result)
        }
    }

    return entities[:]
}


query_3 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid) -> []QueryResult3(T1, T2, T3) {
    entities := make([dynamic]QueryResult3(T1, T2, T3), context.temp_allocator)
    matchCounts:map[Entity]int
    lookups:[3]^map[Entity]int

    lookups[0] = _query_lookup_count_for_type(world, &matchCounts, T1)
    if lookups[0] == nil do return entities[:]
    lookups[1] = _query_lookup_count_for_type(world, &matchCounts, T2)
    if lookups[1] == nil do return entities[:]
    lookups[2] = _query_lookup_count_for_type(world, &matchCounts, T3)
    if lookups[2] == nil do return entities[:]
    
    for entity, count in matchCounts {
        if count == 3 {
            result:QueryResult3(T1, T2, T3)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, lookups[0], T1)
            result.value2 = _query_get_component_from_lookup(world, entity, lookups[1], T2)
            result.value3 = _query_get_component_from_lookup(world, entity, lookups[2], T3)
            append(&entities, result)
        }
    }

    return entities[:]
}

query_4 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid) -> []QueryResult4(T1, T2, T3, T4) {
    entities := make([dynamic]QueryResult4(T1, T2, T3, T4), context.temp_allocator)
    matchCounts:map[Entity]int
    lookups:[4]^map[Entity]int

    lookups[0] = _query_lookup_count_for_type(world, &matchCounts, T1)
    if lookups[0] == nil do return entities[:]
    lookups[1] = _query_lookup_count_for_type(world, &matchCounts, T2)
    if lookups[1] == nil do return entities[:]
    lookups[2] = _query_lookup_count_for_type(world, &matchCounts, T3)
    if lookups[2] == nil do return entities[:]
    lookups[3] = _query_lookup_count_for_type(world, &matchCounts, T4)
    if lookups[3] == nil do return entities[:]
    
    for entity, count in matchCounts {
        if count == 4 {
            result:QueryResult4(T1, T2, T3, T4)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, lookups[0], T1)
            result.value2 = _query_get_component_from_lookup(world, entity, lookups[1], T2)
            result.value3 = _query_get_component_from_lookup(world, entity, lookups[2], T3)
            result.value4 = _query_get_component_from_lookup(world, entity, lookups[3], T4)
            append(&entities, result)
        }
    }

    return entities[:]
}


query_5 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid) -> []QueryResult5(T1, T2, T3, T4, T5) {
    entities := make([dynamic]QueryResult5(T1, T2, T3, T4, T5), context.temp_allocator)
    matchCounts:map[Entity]int
    lookups:[5]^map[Entity]int

    lookups[0] = _query_lookup_count_for_type(world, &matchCounts, T1)
    if lookups[0] == nil do return entities[:]
    lookups[1] = _query_lookup_count_for_type(world, &matchCounts, T2)
    if lookups[1] == nil do return entities[:]
    lookups[2] = _query_lookup_count_for_type(world, &matchCounts, T3)
    if lookups[2] == nil do return entities[:]
    lookups[3] = _query_lookup_count_for_type(world, &matchCounts, T4)
    if lookups[3] == nil do return entities[:]
    lookups[4] = _query_lookup_count_for_type(world, &matchCounts, T5)
    if lookups[4] == nil do return entities[:]
    
    for entity, count in matchCounts {
        if count == 5 {
            result:QueryResult5(T1, T2, T3, T4, T5)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, lookups[0], T1)
            result.value2 = _query_get_component_from_lookup(world, entity, lookups[1], T2)
            result.value3 = _query_get_component_from_lookup(world, entity, lookups[2], T3)
            result.value4 = _query_get_component_from_lookup(world, entity, lookups[3], T4)
            result.value5 = _query_get_component_from_lookup(world, entity, lookups[4], T5)
            append(&entities, result)
        }
    }

    return entities[:]
}

query_6 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid) -> []QueryResult6(T1, T2, T3, T4, T5, T6) {
    entities := make([dynamic]QueryResult6(T1, T2, T3, T4, T5, T6), context.temp_allocator)
    matchCounts:map[Entity]int
    lookups:[6]^map[Entity]int

    lookups[0] = _query_lookup_count_for_type(world, &matchCounts, T1)
    if lookups[0] == nil do return entities[:]
    lookups[1] = _query_lookup_count_for_type(world, &matchCounts, T2)
    if lookups[1] == nil do return entities[:]
    lookups[2] = _query_lookup_count_for_type(world, &matchCounts, T3)
    if lookups[2] == nil do return entities[:]
    lookups[3] = _query_lookup_count_for_type(world, &matchCounts, T4)
    if lookups[3] == nil do return entities[:]
    lookups[4] = _query_lookup_count_for_type(world, &matchCounts, T5)
    if lookups[4] == nil do return entities[:]
    lookups[5] = _query_lookup_count_for_type(world, &matchCounts, T6)
    if lookups[5] == nil do return entities[:]
    
    for entity, count in matchCounts {
        if count == 6 {
            result:QueryResult6(T1, T2, T3, T4, T5, T6)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, lookups[0], T1)
            result.value2 = _query_get_component_from_lookup(world, entity, lookups[1], T2)
            result.value3 = _query_get_component_from_lookup(world, entity, lookups[2], T3)
            result.value4 = _query_get_component_from_lookup(world, entity, lookups[3], T4)
            result.value5 = _query_get_component_from_lookup(world, entity, lookups[4], T5)
            result.value6 = _query_get_component_from_lookup(world, entity, lookups[5], T6)
            append(&entities, result)
        }
    }

    return entities[:]
}

query_7 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid) -> []QueryResult7(T1, T2, T3, T4, T5, T6, T7) {
    entities := make([dynamic]QueryResult7(T1, T2, T3, T4, T5, T6, T7), context.temp_allocator)
    matchCounts:map[Entity]int
    lookups:[7]^map[Entity]int

    lookups[0] = _query_lookup_count_for_type(world, &matchCounts, T1)
    if lookups[0] == nil do return entities[:]
    lookups[1] = _query_lookup_count_for_type(world, &matchCounts, T2)
    if lookups[1] == nil do return entities[:]
    lookups[2] = _query_lookup_count_for_type(world, &matchCounts, T3)
    if lookups[2] == nil do return entities[:]
    lookups[3] = _query_lookup_count_for_type(world, &matchCounts, T4)
    if lookups[3] == nil do return entities[:]
    lookups[4] = _query_lookup_count_for_type(world, &matchCounts, T5)
    if lookups[4] == nil do return entities[:]
    lookups[5] = _query_lookup_count_for_type(world, &matchCounts, T6)
    if lookups[5] == nil do return entities[:]
    lookups[6] = _query_lookup_count_for_type(world, &matchCounts, T7)
    if lookups[6] == nil do return entities[:]
    
    for entity, count in matchCounts {
        if count == 7 {
            result:QueryResult7(T1, T2, T3, T4, T5, T6, T7)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, lookups[0], T1)
            result.value2 = _query_get_component_from_lookup(world, entity, lookups[1], T2)
            result.value3 = _query_get_component_from_lookup(world, entity, lookups[2], T3)
            result.value4 = _query_get_component_from_lookup(world, entity, lookups[3], T4)
            result.value5 = _query_get_component_from_lookup(world, entity, lookups[4], T5)
            result.value6 = _query_get_component_from_lookup(world, entity, lookups[5], T6)
            result.value7 = _query_get_component_from_lookup(world, entity, lookups[6], T7)
            append(&entities, result)
        }
    }

    return entities[:]
}

query_8 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid) -> []QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8) {
    entities := make([dynamic]QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8), context.temp_allocator)
    matchCounts:map[Entity]int
    lookups:[8]^map[Entity]int

    lookups[0] = _query_lookup_count_for_type(world, &matchCounts, T1)
    if lookups[0] == nil do return entities[:]
    lookups[1] = _query_lookup_count_for_type(world, &matchCounts, T2)
    if lookups[1] == nil do return entities[:]
    lookups[2] = _query_lookup_count_for_type(world, &matchCounts, T3)
    if lookups[2] == nil do return entities[:]
    lookups[3] = _query_lookup_count_for_type(world, &matchCounts, T4)
    if lookups[3] == nil do return entities[:]
    lookups[4] = _query_lookup_count_for_type(world, &matchCounts, T5)
    if lookups[4] == nil do return entities[:]
    lookups[5] = _query_lookup_count_for_type(world, &matchCounts, T6)
    if lookups[5] == nil do return entities[:]
    lookups[6] = _query_lookup_count_for_type(world, &matchCounts, T7)
    if lookups[6] == nil do return entities[:]
    lookups[7] = _query_lookup_count_for_type(world, &matchCounts, T8)
    if lookups[7] == nil do return entities[:]
    
    for entity, count in matchCounts {
        if count == 8 {
            result:QueryResult8(T1, T2, T3, T4, T5, T6, T7, T8)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, lookups[0], T1)
            result.value2 = _query_get_component_from_lookup(world, entity, lookups[1], T2)
            result.value3 = _query_get_component_from_lookup(world, entity, lookups[2], T3)
            result.value4 = _query_get_component_from_lookup(world, entity, lookups[3], T4)
            result.value5 = _query_get_component_from_lookup(world, entity, lookups[4], T5)
            result.value6 = _query_get_component_from_lookup(world, entity, lookups[5], T6)
            result.value7 = _query_get_component_from_lookup(world, entity, lookups[6], T7)
            result.value8 = _query_get_component_from_lookup(world, entity, lookups[7], T8)
            append(&entities, result)
        }
    }

    return entities[:]
}

query_9 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid, $T9:typeid) -> []QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9) {
    entities := make([dynamic]QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9), context.temp_allocator)
    matchCounts:map[Entity]int
    lookups:[9]^map[Entity]int

    lookups[0] = _query_lookup_count_for_type(world, &matchCounts, T1)
    if lookups[0] == nil do return entities[:]
    lookups[1] = _query_lookup_count_for_type(world, &matchCounts, T2)
    if lookups[1] == nil do return entities[:]
    lookups[2] = _query_lookup_count_for_type(world, &matchCounts, T3)
    if lookups[2] == nil do return entities[:]
    lookups[3] = _query_lookup_count_for_type(world, &matchCounts, T4)
    if lookups[3] == nil do return entities[:]
    lookups[4] = _query_lookup_count_for_type(world, &matchCounts, T5)
    if lookups[4] == nil do return entities[:]
    lookups[5] = _query_lookup_count_for_type(world, &matchCounts, T6)
    if lookups[5] == nil do return entities[:]
    lookups[6] = _query_lookup_count_for_type(world, &matchCounts, T7)
    if lookups[6] == nil do return entities[:]
    lookups[7] = _query_lookup_count_for_type(world, &matchCounts, T8)
    if lookups[7] == nil do return entities[:]
    lookups[8] = _query_lookup_count_for_type(world, &matchCounts, T9)
    if lookups[8] == nil do return entities[:]
    
    for entity, count in matchCounts {
        if count == 8 {
            result:QueryResult9(T1, T2, T3, T4, T5, T6, T7, T8, T9)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, lookups[0], T1)
            result.value2 = _query_get_component_from_lookup(world, entity, lookups[1], T2)
            result.value3 = _query_get_component_from_lookup(world, entity, lookups[2], T3)
            result.value4 = _query_get_component_from_lookup(world, entity, lookups[3], T4)
            result.value5 = _query_get_component_from_lookup(world, entity, lookups[4], T5)
            result.value6 = _query_get_component_from_lookup(world, entity, lookups[5], T6)
            result.value7 = _query_get_component_from_lookup(world, entity, lookups[6], T7)
            result.value8 = _query_get_component_from_lookup(world, entity, lookups[7], T8)
            result.value9 = _query_get_component_from_lookup(world, entity, lookups[8], T9)
            append(&entities, result)
        }
    }

    return entities[:]
}

query_10 :: proc(world:^World, $T1:typeid, $T2:typeid, $T3:typeid, $T4:typeid, $T5:typeid, $T6:typeid, $T7:typeid, $T8:typeid, $T9:typeid, $T10:typeid) -> []QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10) {
    entities := make([dynamic]QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10), context.temp_allocator)
    matchCounts:map[Entity]int
    lookups:[10]^map[Entity]int

    lookups[0] = _query_lookup_count_for_type(world, &matchCounts, T1)
    if lookups[0] == nil do return entities[:]
    lookups[1] = _query_lookup_count_for_type(world, &matchCounts, T2)
    if lookups[1] == nil do return entities[:]
    lookups[2] = _query_lookup_count_for_type(world, &matchCounts, T3)
    if lookups[2] == nil do return entities[:]
    lookups[3] = _query_lookup_count_for_type(world, &matchCounts, T4)
    if lookups[3] == nil do return entities[:]
    lookups[4] = _query_lookup_count_for_type(world, &matchCounts, T5)
    if lookups[4] == nil do return entities[:]
    lookups[5] = _query_lookup_count_for_type(world, &matchCounts, T6)
    if lookups[5] == nil do return entities[:]
    lookups[6] = _query_lookup_count_for_type(world, &matchCounts, T7)
    if lookups[6] == nil do return entities[:]
    lookups[7] = _query_lookup_count_for_type(world, &matchCounts, T8)
    if lookups[7] == nil do return entities[:]
    lookups[8] = _query_lookup_count_for_type(world, &matchCounts, T9)
    if lookups[8] == nil do return entities[:]
    lookups[9] = _query_lookup_count_for_type(world, &matchCounts, T10)
    if lookups[9] == nil do return entities[:]
    
    for entity, count in matchCounts {
        if count == 10 {
            result:QueryResult10(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10)
            result.entity = entity
            result.value1 = _query_get_component_from_lookup(world, entity, lookups[0], T1)
            result.value2 = _query_get_component_from_lookup(world, entity, lookups[1], T2)
            result.value3 = _query_get_component_from_lookup(world, entity, lookups[2], T3)
            result.value4 = _query_get_component_from_lookup(world, entity, lookups[3], T4)
            result.value5 = _query_get_component_from_lookup(world, entity, lookups[4], T5)
            result.value6 = _query_get_component_from_lookup(world, entity, lookups[5], T6)
            result.value7 = _query_get_component_from_lookup(world, entity, lookups[6], T7)
            result.value8 = _query_get_component_from_lookup(world, entity, lookups[7], T8)
            result.value9 = _query_get_component_from_lookup(world, entity, lookups[8], T9)
            result.value10 = _query_get_component_from_lookup(world, entity, lookups[9], T10)
            append(&entities, result)
        }
    }

    return entities[:]
}

query :: proc { query_1, query_2, query_3, query_4, query_5, query_6, query_7, query_8, query_9, query_10 }

@(private="file")
_query_lookup_count_for_type :: proc(world:^World, matchCounts:^map[Entity]int, $T:typeid) -> ^map[Entity]int {
    lookup, lookupOk := &world.entityComponentLookup[typeid_of(T)]
    if lookupOk {
        for ent in lookup {
            if !isEntityValid(world, ent) do continue
            _, hasEnt := matchCounts[ent]
            matchCounts[ent] = matchCounts[ent] + 1 if hasEnt else 1
        }
    } else do return nil
    return lookup
}

@(private="file")
_query_get_component_from_lookup :: proc(world:^World, entity:Entity, lookup:^map[Entity]int, $T:typeid) -> ^T {
    storageptr := &world.compStorage[T];
    storage := transmute(^[dynamic]T)storageptr;
    compid := lookup[entity]
    return &storage[compid];
}
