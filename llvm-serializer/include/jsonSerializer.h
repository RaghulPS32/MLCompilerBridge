#ifndef JSON_SERIALIZER_H
#define JSON_SERIALIZER_H

#include "baseSerializer.h"
#include "llvm/Support/JSON.h"
#include "llvm/Support/raw_ostream.h"
#include <string>
#include <utility>

using namespace llvm;
using namespace std;

class JsonSerializer : public BaseSerializer {
public:
  JsonSerializer() : BaseSerializer(BaseSerializer::Kind::Json) {
    errs() << "In JsonSerializer constructor...\n";
    errs() << "End JsonSerializer constructor...\n";
  };

  static bool classof(const BaseSerializer *S) {
    return S->getKind() == BaseSerializer::Kind::Json;
  }

  void setFeature(std::string name, int &value) override {
    setFeatureHelper<int>(name, value);
  };
  void setFeature(std::string name, float &value) override {
    errs() << "float val = " << value << "\n";
    setFeatureHelper<float>(name, value);
  };
  void setFeature(std::string name, double &value) override {
    setFeatureHelper<double>(name, value);
  };
  void setFeature(std::string name, std::string &value) override {
    setFeatureHelper<std::string>(name, value);
  };
  void setFeature(std::string name, bool &value) override {
    setFeatureHelper<bool>(name, value);
  };
  // void setFeature(std::string, std::vector<float> &) override;

  std::string getSerializedData() override {
    auto tempJO = J;
    auto data = json::Value(std::move(tempJO));
    std::string ret;
    llvm::raw_string_ostream OS(ret);
    json::OStream(OS).value(data);
    OS << "\n";
    J.clear();
    errs() << "data = " << ret << "\n";
    return ret;
  }

  void *deserializeUntyped(std::string data) override;

private:
  template <class T> void setFeatureHelper(std::string name, T value) {
    errs() << "In JsonSerializer setFeatureHelper...\n";
    errs() << "val = " << value << "\n";
    if (auto X = J.get(name)) {
      if (X->kind() == json::Value::Kind::Array) {
        X->getAsArray()->push_back(value);
      } else {
        J[name] = json::Array({*X, value});
      }
    } else {
      J[name] = value;
    }
  }
  void *desJson(json::Value *V);

private:
  json::Object *Reply;
  json::Value *CurrValue;
  json::Object J;
};

#endif