#!/usr/bin/env python

from argparse import ArgumentParser
from biokbase.cdmi.client import ServerError as CDMIServerError
from biokbase.exchangeformatsupport.reader import pickreader
from biokbase.exchangeformatsupport.userfeedback import TerminalFeedback
from biokbase.experiment.exchangeformat.processor import ExperimentProcessor
from biokbase.exchangeformatsupport.exceptions import ExchangeFormatReaderError
from biokbase.idserver.client import ServerError as IDServerError
import sys
import urllib2

from expression_exchange_format import EXCHANGE_FORMAT
from biokbase.exchangeformatsupport.reader import DelimReader
from biokbase.exchangeformatsupport.reader import ExcelReader

CDMI = 'http://kbase.us/services/cdmi_api'
IDSERVER = 'http://kbase.us/services/idserver'
EXPERIMENT = 'http://kbase.us/services/experiment'

desc = 'Validate exchange format input data for ' + EXCHANGE_FORMAT.name + \
    ' data.'


def parseArgs():
    parser = ArgumentParser(description=desc, prog='validate' + 
                            EXCHANGE_FORMAT.name + 'exchange')
    parser.add_argument('directory', help='Directory where the exchange ' +
                        'format file(s) are stored.')
    parser.add_argument('-t', '--translate-source-ids', action='store_true',
                        dest='trans',
                        help="If a source ID doesn't exist in the load " +
                        'files, try to look it up in the database. ' +
                        'WARNING: if this option is enabled, typos in ' +
                        'source IDs may lead to erroneous linking to ' +
                        'pre-existing IDs in the database.')
    parser.add_argument('-c', '--cdmi', default=CDMI, help='The url ' +
                        'of the cdmi_api service, default ' + CDMI)
    parser.add_argument('-i', '--idserver', default=IDSERVER,
                        help='The url of the idserver, default ' + IDSERVER)
    parser.add_argument('-e', '--experiment', default=EXPERIMENT, 
                        help='The url of the experiment server, default ' + EXPERIMENT) 
    args = parser.parse_args()
    return args.directory, args.experiment, args.cdmi, args.idserver, args.trans


def respondToErr(err, errtype):
    print '\nThere was a ' + errtype + ' error while processing the data. ' + \
            'The reported error was:\n' + str(err)
    sys.exit(1)


if __name__ == '__main__':

    dirc, experiment_url, cdmi, idserver, trans = parseArgs()

    u = TerminalFeedback(sys.stderr)

    try:
        r = pickreader([DelimReader, ExcelReader],
                       dirc, EXCHANGE_FORMAT)
    except ExchangeFormatReaderError as err:
        print err
        sys.exit(1)
    except IOError as err:
        print 'There was an I/O error while trying to read from ' + \
            dirc + '. The reported error was:\n' + str(err)
        sys.exit(1)

    try:
        ExperimentProcessor(r, experiment_url, cdmi, idserver, u, translatesourceids=trans)
    # add better error handling at some point
    except IOError as err:
        respondToErr(err, 'I/O')
    except urllib2.HTTPError as err:
        respondToErr(err, 'http')
    except urllib2.URLError as err:
        respondToErr(err, 'URL')
    except CDMIServerError as err:
        respondToErr(err, 'CDMI service')
    except IDServerError as err:
        respondToErr(err, 'ID service')
