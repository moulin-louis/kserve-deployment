#!/bin/bash
yq eval '(select(.kind == "Gateway") | .spec.gatewayClassName) = "istio"' -
