local module = require("./ecr-19d1fb4/ecr-main/src/ecr")
export type entity  = module.entity 
export type Signal<T...> = module.Signal<T...>
export type Connection  = module.Connection 
export type Handle  = module.Handle 
export type View<T...> = module.View<T...>
export type Observer<T...> = module.Observer<T...>
export type Group<T...> = module.Group<T...>
export type Registry  = module.Registry 
export type Queue<T...> = module.Queue<T...>
return module