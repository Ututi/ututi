#!/usr/bin/env python

import sys


def main(args):
    if len(args) != 2:
        print 'Usage: %s path/to/performance.log'
        sys.exit(1)
    perflog = file(args[1])

    controllers = {}
    users = {}

    for row in perflog:
        try:
            time, level, logger, cls, controller_action, walltime, cputime, uid = row.split()
        except ValueError:
            continue

        # Stats by controller.
        controller_stats = controllers.get(controller_action, (0.0, 0.0, 0))
        controller_stats = (controller_stats[0] + float(walltime),
                            controller_stats[1] + float(cputime),
                            controller_stats[2] + 1)
        controllers[controller_action] = controller_stats

        # Stats by user.
        user_stats = users.get(uid, (0.0, 0.0, 0))
        user_stats = (user_stats[0] + float(walltime),
                      user_stats[1] + float(cputime),
                      user_stats[2] + 1)
        users[uid] = user_stats

    cont_stats = sorted(controllers.items(), key=lambda t: t[1][1], reverse=True)
    user_stats = sorted(users.items(), key=lambda t: t[1][1], reverse=True)

    # Note: all times are approximate, because we are timing concurrent
    # threads at the sime time.  However, the ordering should still be
    # indicative of bottlenecks.

    print 'Statistics (by controller & action)'
    print
    print '%-30s %10s %10s %s' % ('Controller & action', 'CPU time', 'Wall time', 'Hits')
    print '-' * 60
    for controller, (walltime, cputime, hits) in cont_stats:
        print '%-30s %10.4f %10.4f %4d' % (controller, cputime, walltime, hits)

    print
    print 'Statistics (by user)'
    print
    print '%-30s %10s %10s %s' % ('User', 'CPU time', 'Wall time', 'Hits')
    print '-' * 60
    for controller, (walltime, cputime, hits) in user_stats:
        print '%-30s %10.4f %10.4f %4d' % (controller, cputime, walltime, hits)


if __name__ == '__main__':
    main(sys.argv)
