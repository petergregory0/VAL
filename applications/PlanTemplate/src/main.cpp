// Copyright 2019 - University of Strathclyde, King's College London and Schlumberger Ltd
// This source code is licensed under the BSD license found in the LICENSE file in the root directory of this source tree.

#include "valLib.h"
#include "ptree.h"

#include <jinja2cpp/template.h>
#include <jinja2cpp/user_callable.h>
#include <jinja2cpp/reflected_value.h>


#include <iostream>
#include <stdio.h>
#include <vector>

#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iostream>
#include <iomanip>
#include <algorithm>
#include <sstream>
#include <utility>
#include <chrono>


// using namespace std;
using namespace jinja2;


#include "FlexLexer.h"
#include "VisitController.h"

using std::ifstream;
using std::map;
using std::ofstream;
using std::stringstream;
using std::vector;

// using namespace VAL;
// using namespace std;

namespace VAL {

  extern analysis *current_analysis;
  extern parse_category *top_thing;
  extern analysis an_analysis;
  extern yyFlexLexer *yfl;
}  // namespace VAL
extern int yyparse();
extern int yydebug;

char* domainFile;
char* problemFile;
char* planFile;
char* templateFile;

std::string getActionString(const VAL::plan_step* action);
class SimpleAction {
  public:
    std::string actionStr;
    double start_time;
    double duration;
    SimpleAction() {};
    virtual ~SimpleAction(){};
    SimpleAction(VAL::plan_step* plan_step) : actionStr(getActionString(plan_step)), start_time(plan_step->start_time), duration(plan_step->duration) {};
    SimpleAction(const SimpleAction& act) : actionStr(act.actionStr),start_time(act.start_time),duration(act.duration) {};
};

class VariableInterval { 
  public:
    std::pair<double,double> interval;
    VariableInterval(double open) : interval(std::make_pair<double,double>(double(open),-1.0)), complete(false) {};
    VariableInterval(double open, double close) : interval(std::make_pair<double,double>(double(open),double(close))), complete(true) {};
    virtual ~VariableInterval(){};
    bool complete;
};

std::map< std::string, std::vector<VariableInterval> > litIntervals;

std::vector< SimpleAction > thePlan;

std::string getActionString(const VAL::plan_step* action) {
  std::string ret;
  ret = "(" + action->op_sym->getName();
  for (auto param : *(action->params))
    ret += " " + param->getName();
  ret += ")";
  return ret;
}

std::vector<std::string> splitPDDLVec(const std::string predOrFuncOrAction) {
  std::vector<std::string> items;
  std::string minusBrackets = predOrFuncOrAction.substr( 1, predOrFuncOrAction.length()-2 );
  std::istringstream iss(minusBrackets);
  std::vector<std::string> results((std::istream_iterator<std::string>(iss)),
                                    std::istream_iterator<std::string>());
  return results;
}

namespace jinja2 {
  template<>
  struct TypeReflection<SimpleAction> : TypeReflected<SimpleAction>
  {
      static auto& GetAccessors()
      {
          static std::unordered_map<std::string, FieldAccessor> accessors = {
              {"time",     [](const SimpleAction& obj) {return obj.start_time;}},
              {"action",   [](const SimpleAction& obj) {return obj.actionStr;}},
              {"action_name",   [](const SimpleAction& obj) {
                      std::vector<std::string> splitAct = splitPDDLVec(obj.actionStr); 
                      return splitAct[0];}},              
              {"duration", [](const SimpleAction& obj) {return obj.duration;}},
              {"end_time", [](const SimpleAction& obj) {return obj.start_time + obj.duration;}}
          };
          accessors["action_param_0"] = [](const SimpleAction& obj) {
            std::vector<std::string> splitAct = splitPDDLVec(obj.actionStr); 
            return splitAct[1];};
          accessors["action_param_1"] = [](const SimpleAction& obj) {
            std::vector<std::string> splitAct = splitPDDLVec(obj.actionStr); 
            return splitAct[2];};
          accessors["action_param_2"] = [](const SimpleAction& obj) {
            std::vector<std::string> splitAct = splitPDDLVec(obj.actionStr); 
            return splitAct[3];};
          accessors["action_param_3"] = [](const SimpleAction& obj) {
            std::vector<std::string> splitAct = splitPDDLVec(obj.actionStr); 
            return splitAct[4];};
          return accessors;
      }
  };

  // template<>
  // struct TypeReflection< std::pair< std::string, std::vector<VariableInterval> > > : TypeReflected< std::pair< std::string, std::vector<VariableInterval> > >
  // {
  //     static auto& GetAccessors()
  //     {
  //         static std::unordered_map<std::string, FieldAccessor> accessors = {
  //             {"variable",  [](const std::pair< std::string, std::vector<VariableInterval> >& obj) {cout << "R:" << obj.first << std::endl; return obj.first;}},
  //             {"intervals", [](const std::pair< std::string, std::vector<VariableInterval> >& obj) {return jinja2::Reflect(obj.second);}}
  //         };

  //         return accessors;
  //     }
  // };
  
  template<>
  struct TypeReflection< VariableInterval > : TypeReflected< VariableInterval >
  {
      static auto& GetAccessors()
      {
          static std::unordered_map<std::string, FieldAccessor> accessors = {
              {"start",  [](const VariableInterval& obj) {return Value(obj.interval.first);}},
              {"end",    [](const VariableInterval& obj) {return Value(obj.interval.second);}}
          };

          return accessors;
      }
  };
};


std::string getPredicateString(const void *val, unsigned long code){
  int n = 0;

  LPCSTR *arr = whatLit(val, code, n);
  std::string ret = "(";
  for (int i = 0; i < n-1; ++i)
    ret += std::string(arr[i]) + " ";
  ret += std::string(arr[n-1]) + ")";
  delete[] arr;
  return ret;
}

//  pred->prop->args->begin(),->end(),std::back_inserter(arg_list),
//          [](VAL::parameter_symbol *ob) { return Value(ob->getName()); });
std::string getPredicateString(VAL::simple_effect *pred){
  std::string ret = "(" + pred->prop->head->getName();
  for (auto arg : *(pred->prop->args))
    ret += " " + arg->getName();
  ret += ")";
  return ret;
}

std::string getFunctionString(const void *val, unsigned long code){
  int n = 0;

  LPCSTR *arr = whatFun(val, code, n);
  std::string ret = "(";
  for (int i = 0; i < n-1; ++i)
    ret += std::string(arr[i]) + " ";
  ret += std::string(arr[n-1]) + ")";
  return ret;
}

void * makeVal(){
  VAL::current_analysis = &VAL::an_analysis;
  ifstream plan(planFile);
  VAL::yfl = new yyFlexLexer(&plan, &std::cerr);
  yydebug = 0;
  yyparse();
  delete VAL::yfl;
  VAL::parse_category *tt = VAL::top_thing;
  VAL::top_thing = 0;

  void *vld = makeValidatorFromFiles(domainFile, problemFile, 0.001);
  int aID = 1;

  int acts = 0;
  thePlan.clear();
  for (auto &the_plan_step : *((VAL::plan*)tt)){

    std::vector<std::string> params;
    params.push_back(the_plan_step->op_sym->getName());
    std::transform(the_plan_step->params->begin(),the_plan_step->params->end(),
                   std::back_inserter(params),
                   [](VAL::const_symbol *p){
                     return p->getName();});
    LPCSTR actArr[params.size()];
    for (int i = 0; i < params.size(); ++i){  
      char* myStr = strdup(params[i].c_str());
      actArr[i] = myStr;
    }

    post(vld, acts,   actArr, true,  the_plan_step->start_time);


    thePlan.push_back(SimpleAction(the_plan_step));
    
    if (the_plan_step->duration_given)
      post(vld, acts++, actArr, false, the_plan_step->start_time+the_plan_step->duration);

    // delete[] actArr;
  }

  return vld;
}

LPCSTR *splitPDDL(std::string predOrFunc) {
  std::vector<std::string> items;
  std::string minusBrackets = predOrFunc.substr( 1, predOrFunc.length()-2 );
  std::istringstream iss(minusBrackets);
  std::vector<std::string> results((std::istream_iterator<std::string>(iss)),
                                    std::istream_iterator<std::string>());

  LPCSTR *ret = new LPCSTR[results.size()];
  for (int i = 0; i < results.size(); ++i){
    char* t = new char[results[i].size()];
    strcpy(t, results[i].c_str());
    ret[i] = t;
  }
  return ret;
}


bool trueAt(void *vld, std::string lit, double t) {
  // cleanUp(vld);
  void *val = makeVal();
  LPCSTR *litr = splitPDDL(lit);
  bool isTrue = queryLiteralNamed(val, litr);
  double time = -1.0;
  while (time < t && getTime(val) > time){
    time = getTime(val);
    isTrue = queryLiteralNamed(val, litr);
    executeNext(val);
    // time = getTime(val);
  }
  delete[] litr;
  return isTrue;
}

std::string getPDDLString(void* vld, unsigned long code){
  int n;
  LPCSTR *arr = whatLit(vld,code,n);
  std::string ret = "(";
  for (int i = 0; i < n-1; ++i)
    ret += std::string(arr[i]) + " ";
  ret += std::string(arr[n-1]) + ")";
  delete[] arr;
  return ret;
}



void computeIntervalsLit(void *vld) {
  for (VAL::simple_effect *pred : VAL::current_analysis->the_problem->initial_state->add_effects) {
    litIntervals[getPredicateString(pred)].push_back(VariableInterval(0.0));
  }

  double time = -1.0;
  int act = 0;
  while (getTime(vld) > time) {
    int n;
    unsigned long *arr = getChangedLits(vld,n);
    for (int i = 0; i < n; ++i){
      std::string strPred = getPDDLString(vld,arr[i]);
      if (queryLiteralCode(vld,arr[i]) == 0 && !litIntervals[strPred].back().complete) {
        litIntervals[strPred].back().interval.second = getTime(vld);
        litIntervals[strPred].back().complete        = true;
      } else if (queryLiteralCode(vld,arr[i]) == 1) {
        bool addNew = litIntervals[strPred].size() == 0 ? true : litIntervals[strPred].back().complete;
        if (addNew) {
          VariableInterval varInt(getTime(vld));
          litIntervals[strPred].push_back(varInt);
        }
      }          
    }
    delete[] arr;
    time = getTime(vld);
    executeNext(vld);
  }

  for (auto kv : litIntervals) {
    if (!kv.second.back().complete) {
      // cout << kv.first << " incomplete @ " << getTime(vld) << "\n";
      litIntervals[kv.first].back().complete = true;
      litIntervals[kv.first].back().interval.second = getTime(vld);
    }
  }
}

std::vector< ValuesList > getIntervalsLit(std::string lit) {

}

std::vector< ValuesList > getIntervalsFun(std::string fun) {

}

auto start = std::chrono::system_clock::now();

int main(int argc, char *argv[]) {

  cout << argv[1] << " " << argv[2] << std::endl;
  domainFile   = argv[1];
  problemFile  = argv[2];
  planFile     = argv[3];
  templateFile = argv[4]; 
  
  void *vld = makeVal();

  computeIntervalsLit(vld);
  jinja2::ValuesList objectNames;
  std::transform (VAL::current_analysis->the_problem->objects->begin(),
                  VAL::current_analysis->the_problem->objects->end(),
                  std::back_inserter(objectNames),
                  [](VAL::const_symbol *ob) { return jinja2::Value(ob->getName()); });                            

  jinja2::ValuesList objects;
  std::transform (VAL::current_analysis->the_problem->objects->begin(),
                  VAL::current_analysis->the_problem->objects->end(),
                  std::back_inserter(objects),
                  [](VAL::const_symbol *ob) { return jinja2::ValuesMap{ {"name", std::string(ob->getName())},
                                                                        {"type", std::string(ob->type->getName())} }; });

  jinja2::ValuesList initial_state;
  std::transform (VAL::current_analysis->the_problem->initial_state->add_effects.begin(),
                  VAL::current_analysis->the_problem->initial_state->add_effects.end(),
                  std::back_inserter(initial_state),
                  [](VAL::simple_effect *pred) {  ValuesList arg_list;
                                                  std::transform( pred->prop->args->begin(),pred->prop->args->end(),std::back_inserter(arg_list),
                                                                  [](VAL::parameter_symbol *ob) { return Value(ob->getName()); });
                                                  return jinja2::ValuesMap{ {"predicate", std::string(pred->prop->head->getName())},
                                                                            {"arguments", arg_list} }; });

  jinja2::ValuesList initial_state_assignments;
  std::transform (VAL::current_analysis->the_problem->initial_state->assign_effects.begin(),
                  VAL::current_analysis->the_problem->initial_state->assign_effects.end(),
                  std::back_inserter(initial_state_assignments),
                  [](VAL::assignment *func) {  ValuesList arg_list;
                                               std::transform( func->getFTerm()->getArgs()->begin(),func->getFTerm()->getArgs()->end(),std::back_inserter(arg_list),
                                                               [](VAL::parameter_symbol *ob) { return Value(ob->getName()); });
                                               VAL::num_expression* expr;
                                               expr = (VAL::num_expression*)func->getExpr();
                                               return jinja2::ValuesMap{ {"function", std::string(func->getFTerm()->getFunction()->getName())},
                                                                         {"arguments", arg_list},
                                                                         {"assignment", (double)(((VAL::num_expression*)(func->getExpr()))->double_value()) } 
                                                                         }; });


  jinja2::ValuesList intervals;
  std::transform (litIntervals.begin(),
                  litIntervals.end(),
                  std::back_inserter(intervals),
                  [](const std::pair< std::string, std::vector<VariableInterval> > &obj) {
                    jinja2::ValuesList theInts;
                    std::transform( obj.second.begin(),obj.second.end(),std::back_inserter(theInts),
                                    [](const VariableInterval &ob) { 
                                      return ValuesMap{{"start", ob.interval.first}, {"end", ob.interval.second}};
                                      // cout << "x" << ob.interval.first; 
                                      // return Reflect(ob); 
                                    });

                    return jinja2::ValuesMap{ 
                      {"variable",  obj.first},
                      {"intervals", theInts}
                    };
                  });


  auto itt   = std::chrono::system_clock::to_time_t(start);
  std::ostringstream ss;
  ss << std::put_time(gmtime(&itt), "%FT%TZ");

  jinja2::ValuesMap extParams { 
    {"time", ss.str()}
  };

  jinja2::ValuesMap params {
    {"domain" , jinja2::ValuesMap{ {"name",          VAL::current_analysis->the_domain->name} } },
    {"problem", jinja2::ValuesMap{ {"name",          std::string(VAL::current_analysis->the_problem->name)}, 
                                   {"domain_name",   std::string(VAL::current_analysis->the_problem->domain_name)}, 
                                   {"objects",       objects},
                                   {"initial_state", initial_state},
                                   {"initial_state_assignments", initial_state_assignments}
                                 } },
    {"plan",    jinja2::Reflect(thePlan) },
    {"intervals",    intervals},
    {"params",    extParams}    
  };

    params["cup_it_up"] = MakeCallable(
                [](const std::string& str1) {
                    return str1 + "CUP";
                },
                ArgInfo{"str1"}
    );
    params["time_at"] = MakeCallable(
                [](const double dur) {
                      std::chrono::system_clock::time_point new_time = start + std::chrono::hours(int(dur));
                      auto itt   = std::chrono::system_clock::to_time_t(new_time);
                      std::ostringstream ss;
                      ss << std::put_time(gmtime(&itt), "%FT%TZ");
                      return ss.str();
                },
                ArgInfo{"dur"}
    );
    params["action_name"] = MakeCallable(
                [](const jinja2::GenericMap& action) {
                    std::string actS = action.GetValueByName("action").asString();
                    return splitPDDLVec(actS)[0];
                },
                ArgInfo{"action"}
    );
    params["action_name_eq"] = MakeCallable(
                [](const jinja2::GenericMap& action, const std::string& comp) {
                    std::string actS = action.GetValueByName("action").asString();
                    return splitPDDLVec(actS)[0] == comp;
                },
                ArgInfo{"action"},
                ArgInfo{"comp"}                
    );
    params["action_param"] = MakeCallable(
                [](const jinja2::GenericMap& action, const int param) {
                    std::string actS = action.GetValueByName("action").asString();
                    return splitPDDLVec(actS)[param+1];
                },
                ArgInfo{"action"},ArgInfo{"param"}
    );
    

  // std::string inS = "{{domain.name}}{% for i in [1,2,4] %}{{i}}{% endfor %}\n\n";
  ifstream inFile(templateFile);

  

  jinja2::Template tpl;
  auto x = tpl.Load(inFile,"plan");
  // tpl.Load(inS);

  // cout << (x ? "Successfully loaded template." : ":-(") << std::endl;

  jinja2::Result<std::string> s = tpl.RenderAsString(params);  
  if (s){
    // cout << ":-)" << std::endl;
    cout << s.value();
  } else
    cout << s.error();

  cleanUp(vld);

  return(0);
  
}
