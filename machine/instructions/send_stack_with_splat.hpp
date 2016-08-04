  intptr_t literal = next_int;
  intptr_t count = next_int;
  Object* block = stack_pop();
  Object* ary   = stack_pop();
  Object* recv =  stack_back(count);
  CallSite* call_site = reinterpret_cast<CallSite*>(literal);

  Arguments args(call_site->name(), recv, block, count,
                 stack_back_position(count));

  if(!ary->nil_p()) {
    if(CALL_FLAGS() & CALL_FLAG_CONCAT) {
      args.prepend(state, as<Array>(ary));
    } else {
      args.append(state, as<Array>(ary));
    }
  }

  // TODO: instructions
  // SET_CALL_FLAGS(0);

  Object* ret = call_site->execute(state, args);

  stack_clear(count + 1);

  CHECK_AND_PUSH(ret);

  state->vm()->checkpoint(state);