# Objective works

    Code
      obj
    Message

      -- ObjectiveTestEval -----------------------------------------------------------
      * Domain:
    Output
      <ObjectiveTestEval:f>
      Domain:
      <ParamSet(2)>
             id    class lower upper nlevels        default  value
         <char>   <char> <num> <num>   <num>         <list> <list>
      1:     x1 ParamDbl    -1     1     Inf <NoDefault[0]> [NULL]
      2:     x2 ParamDbl    -1     1     Inf <NoDefault[0]> [NULL]
      Codomain:
      <Codomain(1)>
             id    class lower upper nlevels        default  value
         <char>   <char> <num> <num>   <num>         <list> <list>
      1:      y ParamDbl  -Inf   Inf     Inf <NoDefault[0]> [NULL]

---

    Code
      obj
    Message

      -- ObjectiveTestEvalMany -------------------------------------------------------
      * Domain:
    Output
<<<<<<< HEAD
             id    class lower upper nlevels
         <char>   <char> <num> <num>   <num>
      1:     x1 ParamDbl    -1     1     Inf
      2:     x2 ParamDbl    -1     1     Inf
    Message
      * Codomain:
    Output
             id    class lower upper
         <char>   <char> <num> <num>
      1:      y ParamDbl  -Inf   Inf
=======
      <ObjectiveTestEvalMany:f>
      Domain:
      <ParamSet(2)>
             id    class lower upper nlevels        default  value
         <char>   <char> <num> <num>   <num>         <list> <list>
      1:     x1 ParamDbl    -1     1     Inf <NoDefault[0]> [NULL]
      2:     x2 ParamDbl    -1     1     Inf <NoDefault[0]> [NULL]
      Codomain:
      <Codomain(1)>
             id    class lower upper nlevels        default  value
         <char>   <char> <num> <num>   <num>         <list> <list>
      1:      y ParamDbl  -Inf   Inf     Inf <NoDefault[0]> [NULL]
>>>>>>> main

