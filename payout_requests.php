<?php
require 'inc/checklogin.php';
require 'inc/Connection.php';
require 'inc/header.php';

// Handle payout actions
if (isset($_GET['action']) && isset($_GET['id'])) {
    $payout_id = intval($_GET['id']);
    $action = $_GET['action'];
    
    $payout = $car->query("SELECT * FROM tbl_company_payout WHERE id = $payout_id")->fetch_assoc();
    
    if ($payout) {
        switch ($action) {
            case 'process':
                $car->query("UPDATE tbl_company_payout SET status = 'processing' WHERE id = $payout_id");
                $msg = "Payout marked as processing";
                break;
                
            case 'complete':
                $car->query("UPDATE tbl_company_payout SET status = 'completed', processed_at = NOW() WHERE id = $payout_id");
                
                // Update company wallet
                $company_id = $payout['company_id'];
                $amount = $payout['amount'];
                $car->query("UPDATE tbl_company_wallet SET total_withdrawn = total_withdrawn + $amount WHERE company_id = $company_id");
                
                // Notify company
                $car->query("INSERT INTO tbl_company_notification (company_id, title, description, type, reference_id)
                    VALUES ($company_id, 'Payout Completed', 'Your payout request of {$set['currency']}$amount has been processed.', 'payout', $payout_id)");
                
                $msg = "Payout completed successfully";
                break;
                
            case 'reject':
                $reason = isset($_GET['reason']) ? $car->real_escape_string($_GET['reason']) : 'Request rejected by admin';
                $car->query("UPDATE tbl_company_payout SET status = 'rejected', rejection_reason = '$reason', processed_at = NOW() WHERE id = $payout_id");
                
                // Refund to company wallet
                $company_id = $payout['company_id'];
                $amount = $payout['amount'];
                $car->query("UPDATE tbl_company_wallet SET available_balance = available_balance + $amount WHERE company_id = $company_id");
                
                // Record refund transaction
                $wallet = $car->query("SELECT available_balance FROM tbl_company_wallet WHERE company_id = $company_id")->fetch_assoc();
                $car->query("INSERT INTO tbl_company_wallet_transaction (company_id, type, amount, balance_after, description, reference_type, reference_id)
                    VALUES ($company_id, 'credit', $amount, {$wallet['available_balance']}, 'Payout rejected - refund', 'payout', $payout_id)");
                
                // Notify company
                $car->query("INSERT INTO tbl_company_notification (company_id, title, description, type, reference_id)
                    VALUES ($company_id, 'Payout Rejected', 'Your payout request was rejected. Amount refunded to wallet.', 'payout', $payout_id)");
                
                $msg = "Payout rejected and amount refunded";
                break;
        }
        
        echo "<script>alert('$msg'); window.location='payout_requests.php';</script>";
    }
}

// Filters
$where = "1=1";
if (!empty($_GET['status'])) {
    $status = $car->real_escape_string($_GET['status']);
    $where .= " AND p.status = '$status'";
}
if (!empty($_GET['company_id'])) {
    $company_id = intval($_GET['company_id']);
    $where .= " AND p.company_id = $company_id";
}

// Pagination
$page = isset($_GET['page']) ? intval($_GET['page']) : 1;
$limit = 20;
$offset = ($page - 1) * $limit;

$total = $car->query("SELECT COUNT(*) as cnt FROM tbl_company_payout p WHERE $where")->fetch_assoc()['cnt'];
$payouts = $car->query("SELECT p.*, c.company_name, c.email as company_email
    FROM tbl_company_payout p
    JOIN tbl_company c ON p.company_id = c.id
    WHERE $where 
    ORDER BY p.requested_at DESC 
    LIMIT $limit OFFSET $offset");

// Stats
$stats = $car->query("SELECT 
    COALESCE(SUM(CASE WHEN status = 'pending' THEN amount END), 0) as pending_amount,
    COALESCE(SUM(CASE WHEN status = 'processing' THEN amount END), 0) as processing_amount,
    COALESCE(SUM(CASE WHEN status = 'completed' THEN amount END), 0) as completed_amount,
    COUNT(CASE WHEN status = 'pending' THEN 1 END) as pending_count,
    COUNT(CASE WHEN status = 'processing' THEN 1 END) as processing_count
FROM tbl_company_payout")->fetch_assoc();
?>

<div class="page-wrapper">
    <div class="page-content">
        <div class="page-breadcrumb d-none d-sm-flex align-items-center mb-3">
            <div class="breadcrumb-title pe-3">Payout Requests</div>
            <div class="ps-3">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0 p-0">
                        <li class="breadcrumb-item"><a href="dashboard.php"><i class="bx bx-home-alt"></i></a></li>
                        <li class="breadcrumb-item active">Payout Requests</li>
                    </ol>
                </nav>
            </div>
        </div>

        <!-- Stats -->
        <div class="row mb-4">
            <div class="col-md-3">
                <div class="card bg-warning">
                    <div class="card-body text-white">
                        <h4><?= $set['currency'] ?><?= number_format($stats['pending_amount'], 2) ?></h4>
                        <p class="mb-0">Pending (<?= $stats['pending_count'] ?> requests)</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-info">
                    <div class="card-body text-white">
                        <h4><?= $set['currency'] ?><?= number_format($stats['processing_amount'], 2) ?></h4>
                        <p class="mb-0">Processing (<?= $stats['processing_count'] ?> requests)</p>
                    </div>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card bg-success">
                    <div class="card-body text-white">
                        <h4><?= $set['currency'] ?><?= number_format($stats['completed_amount'], 2) ?></h4>
                        <p class="mb-0">Total Paid Out</p>
                    </div>
                </div>
            </div>
        </div>

        <!-- Filters -->
        <div class="card mb-4">
            <div class="card-body">
                <form method="GET" class="row g-3">
                    <div class="col-md-3">
                        <select name="status" class="form-select">
                            <option value="">All Status</option>
                            <option value="pending" <?= ($_GET['status'] ?? '') == 'pending' ? 'selected' : '' ?>>Pending</option>
                            <option value="processing" <?= ($_GET['status'] ?? '') == 'processing' ? 'selected' : '' ?>>Processing</option>
                            <option value="completed" <?= ($_GET['status'] ?? '') == 'completed' ? 'selected' : '' ?>>Completed</option>
                            <option value="rejected" <?= ($_GET['status'] ?? '') == 'rejected' ? 'selected' : '' ?>>Rejected</option>
                        </select>
                    </div>
                    <div class="col-md-2">
                        <button type="submit" class="btn btn-primary">Filter</button>
                        <a href="payout_requests.php" class="btn btn-secondary">Reset</a>
                    </div>
                </form>
            </div>
        </div>

        <!-- Payouts Table -->
        <div class="card">
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-striped table-bordered">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Company</th>
                                <th>Amount</th>
                                <th>Payment Method</th>
                                <th>Account Details</th>
                                <th>Status</th>
                                <th>Requested</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php while ($row = $payouts->fetch_assoc()): ?>
                            <tr>
                                <td><?= $row['id'] ?></td>
                                <td>
                                    <a href="company_details.php?id=<?= $row['company_id'] ?>">
                                        <?= $row['company_name'] ?>
                                    </a>
                                    <br><small class="text-muted"><?= $row['company_email'] ?></small>
                                </td>
                                <td><strong><?= $set['currency'] ?><?= number_format($row['amount'], 2) ?></strong></td>
                                <td><?= ucfirst(str_replace('_', ' ', $row['payment_method'])) ?></td>
                                <td>
                                    <?php if ($row['payment_method'] == 'bank_transfer'): ?>
                                    <small>
                                        Bank: <?= $row['bank_name'] ?><br>
                                        A/C: <?= $row['account_number'] ?><br>
                                        Name: <?= $row['account_name'] ?>
                                    </small>
                                    <?php elseif ($row['payment_method'] == 'paypal'): ?>
                                    <small>PayPal: <?= $row['paypal_email'] ?></small>
                                    <?php elseif ($row['payment_method'] == 'mobile_money'): ?>
                                    <small>Mobile: <?= $row['mobile_money_number'] ?></small>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <?php
                                    $badge = match($row['status']) {
                                        'pending' => 'warning',
                                        'processing' => 'info',
                                        'completed' => 'success',
                                        'rejected' => 'danger',
                                        default => 'secondary'
                                    };
                                    ?>
                                    <span class="badge bg-<?= $badge ?>"><?= ucfirst($row['status']) ?></span>
                                    <?php if ($row['status'] == 'rejected' && $row['rejection_reason']): ?>
                                    <br><small class="text-danger"><?= $row['rejection_reason'] ?></small>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <?= date('M d, Y', strtotime($row['requested_at'])) ?>
                                    <br><small class="text-muted"><?= date('H:i', strtotime($row['requested_at'])) ?></small>
                                </td>
                                <td>
                                    <?php if ($row['status'] == 'pending'): ?>
                                    <a href="?action=process&id=<?= $row['id'] ?>" class="btn btn-sm btn-info" onclick="return confirm('Mark as processing?')">
                                        <i class="bx bx-loader"></i> Process
                                    </a>
                                    <a href="?action=reject&id=<?= $row['id'] ?>" class="btn btn-sm btn-danger" onclick="return confirm('Reject this payout?')">
                                        <i class="bx bx-x"></i> Reject
                                    </a>
                                    <?php elseif ($row['status'] == 'processing'): ?>
                                    <a href="?action=complete&id=<?= $row['id'] ?>" class="btn btn-sm btn-success" onclick="return confirm('Mark as completed?')">
                                        <i class="bx bx-check"></i> Complete
                                    </a>
                                    <a href="?action=reject&id=<?= $row['id'] ?>" class="btn btn-sm btn-danger" onclick="return confirm('Reject this payout?')">
                                        <i class="bx bx-x"></i> Reject
                                    </a>
                                    <?php else: ?>
                                    <span class="text-muted">-</span>
                                    <?php endif; ?>
                                </td>
                            </tr>
                            <?php endwhile; ?>
                        </tbody>
                    </table>
                </div>

                <!-- Pagination -->
                <?php
                $total_pages = ceil($total / $limit);
                if ($total_pages > 1):
                ?>
                <nav class="mt-4">
                    <ul class="pagination justify-content-center">
                        <?php for ($i = 1; $i <= $total_pages; $i++): ?>
                        <li class="page-item <?= $i == $page ? 'active' : '' ?>">
                            <a class="page-link" href="?page=<?= $i ?>&status=<?= $_GET['status'] ?? '' ?>"><?= $i ?></a>
                        </li>
                        <?php endfor; ?>
                    </ul>
                </nav>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<?php require 'inc/footer.php'; ?>
