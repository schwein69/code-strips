
:- op(900, xfx, in).

strips(InitState, GoalList, Plan) :-
    strips_impl(InitState, GoalList, [], [], _, RevPlan),
    reverse(RevPlan, Plan).

strips_impl(State, Goal, Plan, _, State, Plan) :-
    subseteq(Goal, State),
    write("Reached goal "), write(Goal), write(" in "), write(State),
    reverse(Plan, ActualPlan),
    write(" through plan "), write(ActualPlan), unindent, newline.

strips_impl(State, Goal, Plan, BadActions, FinalState, FinalPlan) :-
    write("Need to reach "), write(Goal), write(" from "), write(State), indent, newline,
    write (" without using "), write ( BadActions ), indent , newline ,
    SubGoal in Goal,
    not(SubGoal in State),
    write('Attempting goal:  '), write(SubGoal), newline,
    action(SelectedAction, 'if'(PrecList), '+'(AddList), _, _),
    member(SubGoal, AddList),
    write('Choosing Action:  '), write(SelectedAction),
    /* TODO ensure the selected Action is not blacklisted */
    not(member(SelectedAction, BadActions)),
    write(' -- not a bad action.'), newline,
    write('Need to satisfy preconditions of '), write(SelectedAction), write(", that are: "), write(PrecList), newline,
    /* TODO check if SelectedAction can be applied to the current state */
    /* TODO if not, find a SubPlan making Action applicable, __blacklisting Action__ */
    /* TODO if such a SubPlan exists, let TmpState be the state reached by applying SubPlan to State */
    strips_impl(State, PrecList, Plan, [SelectedAction | BadActions], TmpState, TmpPlan),
    apply(TmpState, SelectedAction, NewState),
    strips_impl(NewState, Goal,[SelectedAction | TmpPlan], BadActions, FinalState, FinalPlan).

strips_impl(_, _, _, _, _, _) :-
    unindent, !, fail.

apply(State, Action, NewState) :-
    write('Simulating '), write(Action), newline,
    write('Transition: '), write(State),
    action(Action, 'if'(PrecList), '+'(AddList), '-'(DelList), where(Conditions)),
    subseteq(PrecList, State),
    call(Conditions),
    write(' - '), write(DelList),
    difference(State, DelList, TmpState),
    write(" + "),
    write(AddList), write(" = "),
    union(AddList, TmpState, NewState),
    write(NewState), newline.
