#!/usr/bin/env python3
# -*- encoding:utf-8 -*-
# Copyright 2026 Huawei Technologies Co., Ltd.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import sys
import logging
from kbox_maintainer.checker.checker import Checker


def check(containers):
    print(containers)
    if not sys.platform.startswith('linux'):
        logging.critical("This tool only support linux platform")
        exit(0)

    if not Checker.check_exagear():
        logging.error(
            "exagear not register, using [kbox_maintainer.py recover]")
        return

    checker = Checker()
    checker.check_containers(containers)


def recover(containers):
    print(containers)
    if not sys.platform.startswith('linux'):
        logging.critical("This tool only support linux platform")
        exit(0)

    if not Checker.check_exagear() and not Checker.recover_exagear():
        logging.fatal(
            "exagear cannot recover!!!")
        return

    checker = Checker()
    checker.recover_containers(containers)
